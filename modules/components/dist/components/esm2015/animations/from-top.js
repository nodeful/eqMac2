import { trigger, style, animate, transition } from '@angular/animations';
const DURATION = 100;
const INITIAL_STATE = {
    transform: 'translateY(-100%)'
};
const END_FRAME_STATE = {
    transform: 'translateY(0%)'
};
export const FromTopAnimation = trigger('FromTop', [
    transition(':enter', [
        style(INITIAL_STATE),
        animate(DURATION, style(END_FRAME_STATE))
    ]),
    transition(':leave', [
        animate(DURATION, style(INITIAL_STATE))
    ])
]);
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZnJvbS10b3AuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyIuLi8uLi8uLi8uLi9wcm9qZWN0cy9jb21wb25lbnRzL3NyYy9hbmltYXRpb25zL2Zyb20tdG9wLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLE9BQU8sRUFBRSxPQUFPLEVBQUUsS0FBSyxFQUFFLE9BQU8sRUFBRSxVQUFVLEVBQUUsTUFBTSxxQkFBcUIsQ0FBQTtBQUV6RSxNQUFNLFFBQVEsR0FBRyxHQUFHLENBQUE7QUFFcEIsTUFBTSxhQUFhLEdBQUc7SUFDcEIsU0FBUyxFQUFFLG1CQUFtQjtDQUMvQixDQUFBO0FBRUQsTUFBTSxlQUFlLEdBQUc7SUFDdEIsU0FBUyxFQUFFLGdCQUFnQjtDQUM1QixDQUFBO0FBRUQsTUFBTSxDQUFDLE1BQU0sZ0JBQWdCLEdBQUcsT0FBTyxDQUFDLFNBQVMsRUFBRTtJQUNqRCxVQUFVLENBQUMsUUFBUSxFQUFFO1FBQ25CLEtBQUssQ0FBQyxhQUFhLENBQUM7UUFDcEIsT0FBTyxDQUFDLFFBQVEsRUFBRSxLQUFLLENBQUMsZUFBZSxDQUFDLENBQUM7S0FDMUMsQ0FBQztJQUNGLFVBQVUsQ0FBQyxRQUFRLEVBQUU7UUFDbkIsT0FBTyxDQUFDLFFBQVEsRUFBRSxLQUFLLENBQUMsYUFBYSxDQUFDLENBQUM7S0FDeEMsQ0FBQztDQUNILENBQUMsQ0FBQSIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IHRyaWdnZXIsIHN0eWxlLCBhbmltYXRlLCB0cmFuc2l0aW9uIH0gZnJvbSAnQGFuZ3VsYXIvYW5pbWF0aW9ucydcblxuY29uc3QgRFVSQVRJT04gPSAxMDBcblxuY29uc3QgSU5JVElBTF9TVEFURSA9IHtcbiAgdHJhbnNmb3JtOiAndHJhbnNsYXRlWSgtMTAwJSknXG59XG5cbmNvbnN0IEVORF9GUkFNRV9TVEFURSA9IHtcbiAgdHJhbnNmb3JtOiAndHJhbnNsYXRlWSgwJSknXG59XG5cbmV4cG9ydCBjb25zdCBGcm9tVG9wQW5pbWF0aW9uID0gdHJpZ2dlcignRnJvbVRvcCcsIFtcbiAgdHJhbnNpdGlvbignOmVudGVyJywgWyAvLyA6ZW50ZXIgaXMgYWxpYXMgdG8gJ3ZvaWQgPT4gKidcbiAgICBzdHlsZShJTklUSUFMX1NUQVRFKSxcbiAgICBhbmltYXRlKERVUkFUSU9OLCBzdHlsZShFTkRfRlJBTUVfU1RBVEUpKVxuICBdKSxcbiAgdHJhbnNpdGlvbignOmxlYXZlJywgWyAvLyA6bGVhdmUgaXMgYWxpYXMgdG8gJyogPT4gdm9pZCdcbiAgICBhbmltYXRlKERVUkFUSU9OLCBzdHlsZShJTklUSUFMX1NUQVRFKSlcbiAgXSlcbl0pXG4iXX0=