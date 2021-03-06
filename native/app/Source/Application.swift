//
//  Application.swift
//  eqMac
//
//  Created by Roman Kisil on 22/01/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import Cocoa
import AMCoreAudio
import Dispatch
import Sentry
import EmitterKit
import AVFoundation
import SwiftyUserDefaults
import SwiftyJSON
import ServiceManagement
import ReSwift
import Sparkle

enum VolumeChangeDirection: String {
  case UP = "UP"
  case DOWN = "DOWN"
}

class Application {
  static var engine: Engine?
  static var output: Output?
  static var engineCreated = EmitterKit.Event<Void>()
  static var outputCreated = EmitterKit.Event<Void>()

  static var selectedDevice: AudioDevice?
  static var selectedDeviceIsAliveListener: EventListener<AudioDevice>?
  static var selectedDeviceVolumeChangedListener: EventListener<AudioDevice>?
  static var selectedDeviceSampleRateChangedListener: EventListener<AudioDevice>?
  static var justChangedSelectedDeviceVolume = false
  static var lastKnownDeviceStack: [AudioDevice] = []

  static let audioPipelineIsRunning = EmitterKit.Event<Void>()
  static var audioPipelineIsRunningListener: EmitterKit.EventListener<Void>?
  private static var ignoreEvents = false

  static var settings: Settings!
  static var ui: UI!
  
  static var dataBus: DataBus!
  static var updater = SUUpdater(for: Bundle.main)!
  
  static let store: Store = Store(
    reducer: ApplicationStateReducer,
    state: Storage[.state] ?? ApplicationState(),
    middleware: []
  )

  static public func start () {
    if (!Constants.DEBUG) {
      setupCrashReporting()
    }
    
    self.settings = Settings()

    Networking.startMonitor()
    
    Driver.check {
      Sources.getInputPermission {
        AudioDevice.register = true
        audioPipelineIsRunningListener = audioPipelineIsRunning.once {
          self.setupUI {
            if (User.isFirstLaunch) {
              UI.show()
            } else {
              UI.close()
            }
          }
        }
        setupAudio()
      }
    }
  }
  
  private static func setupCrashReporting () {
    // Create a Sentry client and start crash handler
    SentrySDK.start { options in
      options.dsn = Constants.SENTRY_ENDPOINT
      // Only send crash reports if user gave consent
      options.beforeSend = { event in
        if (store.state.settings.doCollectCrashReports) {
          return event
        }
        return nil
      }
    }
  }

  private static func setupAudio () {
    Console.log("Setting up Audio Engine")
    Driver.show {
      setupDeviceEvents()
      startPassthrough()
    }
  }
  
  static var ignoreNextVolumeEvent = false
  
  static func setupDeviceEvents () {
    AudioDeviceEvents.on(.outputChanged) { device in
      if ignoreEvents { return }
      if device.id == Driver.device!.id { return }

      if Outputs.isDeviceAllowed(device) {
        Console.log("outputChanged: ", device, " starting PlayThrough")
        startPassthrough()
      } else {
        // TODO: Tell the user eqMac doesn't support this device
      }
    }
    
    AudioDeviceEvents.onDeviceListChanged { list in
      if ignoreEvents { return }
      Console.log("listChanged", list)
      
      if list.added.count > 0 {
        for added in list.added {
          if Outputs.shouldAutoSelect(added) {
            selectOutput(device: added)
            break
          }
        }
      } else if (list.removed.count > 0) {
        
        let currentDeviceRemoved = list.removed.contains(where: { $0.id == selectedDevice?.id })
        
        if (currentDeviceRemoved) {
          ignoreEvents = true
          removeEngines()
          try! AudioDeviceEvents.recreateEventEmitters([.isAliveChanged, .volumeChanged, .nominalSampleRateChanged])
          self.setupDriverDeviceEvents()
          Utilities.delay(500) {
            selectOutput(device: getLastKnowDeviceFromStack())
          }
        }
      }
      
    }
    AudioDeviceEvents.on(.isJackConnectedChanged) { device in
      if ignoreEvents { return }
      let connected = device.isJackConnected(direction: .playback)
      Console.log("isJackConnectedChanged", device, connected)
      if (device.id != selectedDevice?.id) {
        if (connected == true) {
          selectOutput(device: device)
        }
      } else {
        stopRemoveEngines {
          Utilities.delay(1000) {
            // need a delay, because emitter should finish it's work at first
            try! AudioDeviceEvents.recreateEventEmitters([.isAliveChanged, .volumeChanged, .nominalSampleRateChanged])
            setupDriverDeviceEvents()
            matchDriverSampleRateToOutput()
            createAudioPipeline()
          }
        }
      }
    }
    
    setupDriverDeviceEvents()
  }
  
  static var ignoreNextDriverMuteEvent = false
  static func setupDriverDeviceEvents () {
    AudioDeviceEvents.on(.volumeChanged, onDevice: Driver.device!) {
      if ignoreEvents { return }
      if ignoreNextVolumeEvent {
        ignoreNextVolumeEvent = false
        return
      }
      if (overrideNextVolumeEvent) {
        overrideNextVolumeEvent = false
        ignoreNextVolumeEvent = true
        Driver.device!.setVirtualMasterVolume(1, direction: .playback)
        return
      }
      let gain = Double(Driver.device!.virtualMasterVolume(direction: .playback)!)
      if (gain <= 1 && gain != Application.store.state.volume.gain) {
        Application.dispatchAction(VolumeAction.setGain(gain, false))
      }

    }
    
    AudioDeviceEvents.on(.muteChanged, onDevice: Driver.device!) {
      if ignoreEvents { return }
      if (ignoreNextDriverMuteEvent) {
        ignoreNextDriverMuteEvent = false
        return
      }
      Application.dispatchAction(VolumeAction.setMuted(Driver.device!.mute))
    }
  }
  
  static func selectOutput (device: AudioDevice) {
    ignoreEvents = true
    stopRemoveEngines {
      Utilities.delay(500) {
        ignoreEvents = false
        AudioDevice.currentOutputDevice = device
      }
    }
  }
  
  static func startPassthrough () {
    selectedDevice = AudioDevice.currentOutputDevice

    if (selectedDevice!.id == Driver.device!.id) {
      selectedDevice = getLastKnowDeviceFromStack()
    }

    lastKnownDeviceStack.append(selectedDevice!)

    ignoreEvents = true
    var volume: Double = Application.store.state.volume.gain
    var muted = store.state.volume.muted
    var balance = store.state.volume.balance

    if (selectedDevice!.outputVolumeSupported) {
      volume = Double(selectedDevice!.virtualMasterVolume(direction: .playback)!)
      muted = selectedDevice!.mute
    }

    if (selectedDevice!.outputBalanceSupported) {
      balance = Utilities.mapValue(
        value: Double(selectedDevice!.virtualMasterBalance(direction: .playback)!),
        inMin: 0,
        inMax: 1,
        outMin: -1,
        outMax: 1
      )
    }

    Application.dispatchAction(VolumeAction.setBalance(balance, false))
    Application.dispatchAction(VolumeAction.setGain(volume, false))
    Application.dispatchAction(VolumeAction.setMuted(muted))
    
    Driver.device!.setVirtualMasterVolume(volume > 1 ? 1 : Float32(volume), direction: .playback)
    Driver.latency = selectedDevice!.latency(direction: .playback) ?? 0 // Set driver latency to mimic device
    //    Driver.safetyOffset = selectedDevice.safetyOffset(direction: .playback) ?? 0 // Set driver safetyOffset to mimic device
    self.matchDriverSampleRateToOutput()
    
    Console.log("Driver new Latency: \(Driver.latency)")
    Console.log("Driver new Safety Offset: \(Driver.safetyOffset)")
    Console.log("Driver new Sample Rate: \(Driver.device!.actualSampleRate())")
    
    AudioDevice.currentOutputDevice = Driver.device!
    // TODO: Figure out a better way
    Utilities.delay(1000) {
      ignoreEvents = false
      createAudioPipeline()
    }
  }

  private static func getLastKnowDeviceFromStack () -> AudioDevice {
    var device: AudioDevice?
    if (lastKnownDeviceStack.count > 0) {
      device = lastKnownDeviceStack.removeLast()
    } else {
      return AudioDevice.builtInOutputDevice
    }
    if device == nil { return getLastKnowDeviceFromStack() }

    Console.log("Last known device: \(device!.id) - \(device!.name)")
    let newDevice = Outputs.allowedDevices.first(where: { $0.id == device!.id || $0.name == device!.name })
    if newDevice == nil {
      Console.log("Last known device is not currently available, trying next")
      return getLastKnowDeviceFromStack()
    }
    return newDevice!
  }

  private static func matchDriverSampleRateToOutput () {
    let outputSampleRate = selectedDevice!.actualSampleRate()!
    let driverSampleRates = Driver.sampleRates
    let closestSampleRate = driverSampleRates.min( by: { abs($0 - outputSampleRate) < abs($1 - outputSampleRate) } )!
    Driver.device!.setNominalSampleRate(closestSampleRate)
  }
  
  private static func createAudioPipeline () {
    engine = nil
    engine = Engine {
      engineCreated.emit()
      output = nil
      output = Output(device: selectedDevice!)
      outputCreated.emit()

      selectedDeviceSampleRateChangedListener = AudioDeviceEvents.on(
        .nominalSampleRateChanged,
        onDevice: selectedDevice!,
        retain: false
      ) {
        if ignoreEvents { return }
        ignoreEvents = true
        stopRemoveEngines {
          Utilities.delay(1000) {
            // need a delay, because emitter should finish it's work at first
            try! AudioDeviceEvents.recreateEventEmitters([.isAliveChanged, .volumeChanged, .nominalSampleRateChanged])
            setupDriverDeviceEvents()
            matchDriverSampleRateToOutput()
            createAudioPipeline()
            ignoreEvents = false
          }
        }
      }
      
      selectedDeviceVolumeChangedListener = AudioDeviceEvents.on(
        .volumeChanged,
        onDevice: selectedDevice!,
        retain: false
      ) {
        if ignoreEvents { return }
        let deviceVolume = selectedDevice!.virtualMasterVolume(direction: .playback)!
        let driverVolume = Driver.device!.virtualMasterVolume(direction: .playback)!
        if (deviceVolume != driverVolume) {
          Driver.device!.setVirtualMasterVolume(deviceVolume, direction: .playback)
        }
      }
      audioPipelineIsRunning.emit()
    }
  }
  
  private static func setupUI (_ completion: @escaping () -> Void) {
    Console.log("Setting up UI")
    ui = UI {
      setupDataBus()
      completion()
    }
  }
  
  private static func setupDataBus () {
    Console.log("Setting up Data Bus")
    dataBus = ApplicationDataBus(bridge: UI.bridge)
  }
  
  static var overrideNextVolumeEvent = false
  static func volumeChangeButtonPressed (direction: VolumeChangeDirection, quarterStep: Bool = false) {
    if ignoreEvents || engine == nil || output == nil {
      return
    }
    if direction == .UP {
      ignoreNextDriverMuteEvent = true
      Utilities.delay(100) {
        ignoreNextDriverMuteEvent = false
      }
    }
    let gain = output!.volume.gain
    if (gain >= 1) {
      if direction == .DOWN {
        overrideNextVolumeEvent = true
      }
      
      let steps = quarterStep ? Constants.QUARTER_VOLUME_STEPS : Constants.FULL_VOLUME_STEPS
      
      var stepIndex: Int
      
      if direction == .UP {
        stepIndex = steps.index(where: { $0 > gain }) ?? steps.count - 1
      } else {
        stepIndex = steps.index(where: { $0 >= gain }) ?? 0
        stepIndex -= 1
        if (stepIndex < 0) {
          stepIndex = 0
        }
      }
      
      var newGain = steps[stepIndex]
      
      if (newGain <= 1) {
        Utilities.delay(100) {
          Driver.device!.setVirtualMasterVolume(Float(newGain), direction: .playback)
        }
      } else {
        if (!Application.store.state.volume.boostEnabled) {
          newGain = 1
        }
      }
      Application.dispatchAction(VolumeAction.setGain(newGain, false))
    }
  }
  
  static func muteButtonPressed () {
    ignoreNextDriverMuteEvent = false
  }
  
  private static func switchBackToLastKnownDevice () {
    // If the active equalizer global gain hass been lowered we need to equalize the volume to avoid blowing people ears our
    if (engine == nil || selectedDevice == nil) { return }
    if (engine!.effects != nil && engine!.effects.equalizers.active.globalGain < 0) {
      if (selectedDevice!.canSetVirtualMasterVolume(direction: .playback)) {
        var decibels = selectedDevice!.virtualMasterVolumeInDecibels(direction: .playback)!
        decibels = decibels + Float(engine!.effects.equalizers.active.globalGain)
        selectedDevice!.setVirtualMasterVolume(selectedDevice!.decibelsToScalar(volume: decibels, channel: 1, direction: .playback)!, direction: .playback)
      } else if (selectedDevice!.canSetVolume(channel: 1, direction: .playback)) {
        var decibels = selectedDevice!.volumeInDecibels(channel: 1, direction: .playback)!
        decibels = decibels + Float(engine!.effects.equalizers.active.globalGain)
        for channel in 1...selectedDevice!.channels(direction: .playback) {
          selectedDevice!.setVolume(selectedDevice!.decibelsToScalar(volume: decibels, channel: channel, direction: .playback)!, channel: channel, direction: .playback)
        }
      }
    }
    AudioDevice.currentOutputDevice = selectedDevice!
  }

  static func stopEngines (_ completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      var returned = false
      Utilities.delay(2000) {
        if (!returned) {
          completion()
        }
      }
      output?.stop()
      engine?.stop()
      returned = true
      completion()
    }
  }

  static func removeEngines () {
    output = nil
    engine = nil
  }

  static func stopRemoveEngines (_ completion: @escaping () -> Void) {
    stopEngines {
      removeEngines()
      completion()
    }
  }

  static func stopSave (_ completion: @escaping () -> Void) {
    Storage.synchronize()
    stopListeners()
    stopRemoveEngines {
      switchBackToLastKnownDevice()
      completion()
    }
  }

  static func handleSleep () {
    ignoreEvents = true
    stopSave {}
  }

  static func handleWakeUp () {
    // Wait for devices to initialize, not sure what delay is appropriate
    Utilities.delay(1000) {
      if lastKnownDeviceStack.count == 0 { return setupAudio() }
      let lastDevice = lastKnownDeviceStack.last
      var tries = 0
      let maxTries = 5

      func checkLastKnownDeviceActive () {
        tries += 1
        if tries <= maxTries {
          let newDevice = Outputs.allowedDevices.first(where: { $0.id == lastDevice!.id || $0.name == lastDevice!.name })
          if newDevice != nil && newDevice!.isAlive() && newDevice!.nominalSampleRate() != nil {
            setupAudio()
          } else {
            Utilities.delay(1000) {
              checkLastKnownDeviceActive()
            }
          }
        } else {
          // Tried as much as we could, continue with something else
          setupAudio()
        }
      }

      checkLastKnownDeviceActive()
    }
  }
  
  static func quit (_ completion: (() -> Void)? = nil) {
    stopSave {
      Driver.hidden = true
      if completion != nil {
        completion!()
      }
      NSApp.terminate(nil)
    }
  }
  
  static func restart () {
    let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
    let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
    let task = Process()
    task.launchPath = "/usr/bin/open"
    task.arguments = [path]
    task.launch()
    quit()
  }
  
  static func restartMac () {
    Script.apple("restart_mac")
  }
  
  static func checkForUpdates () {
    updater.checkForUpdates(nil)
  }
  
  static func uninstall () {
    // TODO: Implement uninstaller
    Console.log("// TODO: Download Uninstaller")
  }
  
  static func stopListeners () {
    AudioDeviceEvents.stop()
    selectedDeviceIsAliveListener?.isListening = false
    selectedDeviceIsAliveListener = nil
    
    audioPipelineIsRunningListener?.isListening = false
    audioPipelineIsRunningListener = nil
    
    selectedDeviceVolumeChangedListener?.isListening = false
    selectedDeviceVolumeChangedListener = nil
    
    selectedDeviceSampleRateChangedListener?.isListening = false
    selectedDeviceSampleRateChangedListener = nil
  }
  
  static var version: String {
    return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
  }
  
  static func newState (_ state: ApplicationState) {}
  
  static var supportPath: URL {
    //Create App directory if not exists:
    let fileManager = FileManager()
    let urlPaths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    
    let appDirectory = urlPaths.first!.appendingPathComponent(Bundle.main.bundleIdentifier! ,isDirectory: true)
    var objCTrue: ObjCBool = true
    let path = appDirectory.path
    if !fileManager.fileExists(atPath: path, isDirectory: &objCTrue) {
      try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    return appDirectory
  }
  
  static private let dispatchActionQueue = DispatchQueue(label: "dispatchActionQueue", qos: .userInitiated)
  // Custom dispatch function. Need to execute some dispatches on the main thread
  static func dispatchAction(_ action: Action, onMainThread: Bool = true) {
    if (onMainThread) {
      DispatchQueue.main.async {
        store.dispatch(action)
      }
    } else {
      dispatchActionQueue.async {
        store.dispatch(action)
      }
    }
  }
}

