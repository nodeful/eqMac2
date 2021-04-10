import { Component, Input, HostBinding } from '@angular/core';
import * as i0 from "@angular/core";
export class DividerComponent {
    constructor(elem) {
        this.elem = elem;
        this.orientation = 'horizontal';
    }
    get width() {
        return this.orientation === 'vertical' ? '1px' : `${this.elem.nativeElement.parentElement.offsetWidth}`;
    }
    get height() {
        return this.orientation === 'vertical' ? `${this.elem.nativeElement.parentElement.offsetHeight}` : '1px';
    }
    get leftBorder() {
        return this.orientation === 'vertical' ? '1px solid rgb(58, 59, 61)' : undefined;
    }
    get rightBorder() {
        return this.orientation === 'vertical' ? '1px solid rgb(96, 97, 101)' : undefined;
    }
    get topBorder() {
        return this.orientation === 'horizontal' ? '1px solid rgb(58, 59, 61)' : undefined;
    }
    get bottomtBorder() {
        return this.orientation === 'horizontal' ? '1px solid rgb(96, 97, 101)' : undefined;
    }
}
DividerComponent.ɵfac = function DividerComponent_Factory(t) { return new (t || DividerComponent)(i0.ɵɵdirectiveInject(i0.ElementRef)); };
DividerComponent.ɵcmp = i0.ɵɵdefineComponent({ type: DividerComponent, selectors: [["eqm-divider"]], hostVars: 12, hostBindings: function DividerComponent_HostBindings(rf, ctx) { if (rf & 2) {
        i0.ɵɵstyleProp("width", ctx.width)("height", ctx.height)("border-left", ctx.leftBorder)("border-right", ctx.rightBorder)("border-top", ctx.topBorder)("border-bottom", ctx.bottomtBorder);
    } }, inputs: { orientation: "orientation" }, decls: 0, vars: 0, template: function DividerComponent_Template(rf, ctx) { }, styles: ["[_nghost-%COMP%]{display:block;overflow:hidden;background-color:#000}"] });
(function () { (typeof ngDevMode === "undefined" || ngDevMode) && i0.ɵsetClassMetadata(DividerComponent, [{
        type: Component,
        args: [{
                selector: 'eqm-divider',
                templateUrl: './divider.component.html',
                styleUrls: ['./divider.component.scss']
            }]
    }], function () { return [{ type: i0.ElementRef }]; }, { orientation: [{
            type: Input
        }], width: [{
            type: HostBinding,
            args: ['style.width']
        }], height: [{
            type: HostBinding,
            args: ['style.height']
        }], leftBorder: [{
            type: HostBinding,
            args: ['style.border-left']
        }], rightBorder: [{
            type: HostBinding,
            args: ['style.border-right']
        }], topBorder: [{
            type: HostBinding,
            args: ['style.border-top']
        }], bottomtBorder: [{
            type: HostBinding,
            args: ['style.border-bottom']
        }] }); })();
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZGl2aWRlci5jb21wb25lbnQuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyIuLi8uLi8uLi8uLi8uLi9wcm9qZWN0cy9jb21wb25lbnRzL3NyYy9jb21wb25lbnRzL2RpdmlkZXIvZGl2aWRlci5jb21wb25lbnQudHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUEsT0FBTyxFQUFFLFNBQVMsRUFBRSxLQUFLLEVBQWMsV0FBVyxFQUFFLE1BQU0sZUFBZSxDQUFBOztBQU96RSxNQUFNLE9BQU8sZ0JBQWdCO0lBRzNCLFlBQ1MsSUFBZ0I7UUFBaEIsU0FBSSxHQUFKLElBQUksQ0FBWTtRQUhoQixnQkFBVyxHQUE4QixZQUFZLENBQUE7SUFJM0QsQ0FBQztJQUVKLElBQ0ksS0FBSztRQUNQLE9BQU8sSUFBSSxDQUFDLFdBQVcsS0FBSyxVQUFVLENBQUMsQ0FBQyxDQUFDLEtBQUssQ0FBQyxDQUFDLENBQUMsR0FBRyxJQUFJLENBQUMsSUFBSSxDQUFDLGFBQWEsQ0FBQyxhQUFhLENBQUMsV0FBVyxFQUFFLENBQUE7SUFDekcsQ0FBQztJQUVELElBQ0ksTUFBTTtRQUNSLE9BQU8sSUFBSSxDQUFDLFdBQVcsS0FBSyxVQUFVLENBQUMsQ0FBQyxDQUFDLEdBQUcsSUFBSSxDQUFDLElBQUksQ0FBQyxhQUFhLENBQUMsYUFBYSxDQUFDLFlBQVksRUFBRSxDQUFDLENBQUMsQ0FBQyxLQUFLLENBQUE7SUFDMUcsQ0FBQztJQUVELElBQ0ksVUFBVTtRQUNaLE9BQU8sSUFBSSxDQUFDLFdBQVcsS0FBSyxVQUFVLENBQUMsQ0FBQyxDQUFDLDJCQUEyQixDQUFDLENBQUMsQ0FBQyxTQUFTLENBQUE7SUFDbEYsQ0FBQztJQUVELElBQ0ksV0FBVztRQUNiLE9BQU8sSUFBSSxDQUFDLFdBQVcsS0FBSyxVQUFVLENBQUMsQ0FBQyxDQUFDLDRCQUE0QixDQUFDLENBQUMsQ0FBQyxTQUFTLENBQUE7SUFDbkYsQ0FBQztJQUVELElBQ0ksU0FBUztRQUNYLE9BQU8sSUFBSSxDQUFDLFdBQVcsS0FBSyxZQUFZLENBQUMsQ0FBQyxDQUFDLDJCQUEyQixDQUFDLENBQUMsQ0FBQyxTQUFTLENBQUE7SUFDcEYsQ0FBQztJQUVELElBQ0ksYUFBYTtRQUNmLE9BQU8sSUFBSSxDQUFDLFdBQVcsS0FBSyxZQUFZLENBQUMsQ0FBQyxDQUFDLDRCQUE0QixDQUFDLENBQUMsQ0FBQyxTQUFTLENBQUE7SUFDckYsQ0FBQzs7Z0ZBbkNVLGdCQUFnQjtxREFBaEIsZ0JBQWdCOzs7dUZBQWhCLGdCQUFnQjtjQUw1QixTQUFTO2VBQUM7Z0JBQ1QsUUFBUSxFQUFFLGFBQWE7Z0JBQ3ZCLFdBQVcsRUFBRSwwQkFBMEI7Z0JBQ3ZDLFNBQVMsRUFBRSxDQUFFLDBCQUEwQixDQUFFO2FBQzFDOzZEQUVVLFdBQVc7a0JBQW5CLEtBQUs7WUFPRixLQUFLO2tCQURSLFdBQVc7bUJBQUMsYUFBYTtZQU10QixNQUFNO2tCQURULFdBQVc7bUJBQUMsY0FBYztZQU12QixVQUFVO2tCQURiLFdBQVc7bUJBQUMsbUJBQW1CO1lBTTVCLFdBQVc7a0JBRGQsV0FBVzttQkFBQyxvQkFBb0I7WUFNN0IsU0FBUztrQkFEWixXQUFXO21CQUFDLGtCQUFrQjtZQU0zQixhQUFhO2tCQURoQixXQUFXO21CQUFDLHFCQUFxQiIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IENvbXBvbmVudCwgSW5wdXQsIEVsZW1lbnRSZWYsIEhvc3RCaW5kaW5nIH0gZnJvbSAnQGFuZ3VsYXIvY29yZSdcblxuQENvbXBvbmVudCh7XG4gIHNlbGVjdG9yOiAnZXFtLWRpdmlkZXInLFxuICB0ZW1wbGF0ZVVybDogJy4vZGl2aWRlci5jb21wb25lbnQuaHRtbCcsXG4gIHN0eWxlVXJsczogWyAnLi9kaXZpZGVyLmNvbXBvbmVudC5zY3NzJyBdXG59KVxuZXhwb3J0IGNsYXNzIERpdmlkZXJDb21wb25lbnQge1xuICBASW5wdXQoKSBvcmllbnRhdGlvbjogJ3ZlcnRpY2FsJyB8ICdob3Jpem9udGFsJyA9ICdob3Jpem9udGFsJ1xuXG4gIGNvbnN0cnVjdG9yIChcbiAgICBwdWJsaWMgZWxlbTogRWxlbWVudFJlZlxuICApIHt9XG5cbiAgQEhvc3RCaW5kaW5nKCdzdHlsZS53aWR0aCcpXG4gIGdldCB3aWR0aCAoKSB7XG4gICAgcmV0dXJuIHRoaXMub3JpZW50YXRpb24gPT09ICd2ZXJ0aWNhbCcgPyAnMXB4JyA6IGAke3RoaXMuZWxlbS5uYXRpdmVFbGVtZW50LnBhcmVudEVsZW1lbnQub2Zmc2V0V2lkdGh9YFxuICB9XG5cbiAgQEhvc3RCaW5kaW5nKCdzdHlsZS5oZWlnaHQnKVxuICBnZXQgaGVpZ2h0ICgpIHtcbiAgICByZXR1cm4gdGhpcy5vcmllbnRhdGlvbiA9PT0gJ3ZlcnRpY2FsJyA/IGAke3RoaXMuZWxlbS5uYXRpdmVFbGVtZW50LnBhcmVudEVsZW1lbnQub2Zmc2V0SGVpZ2h0fWAgOiAnMXB4J1xuICB9XG5cbiAgQEhvc3RCaW5kaW5nKCdzdHlsZS5ib3JkZXItbGVmdCcpXG4gIGdldCBsZWZ0Qm9yZGVyICgpIHtcbiAgICByZXR1cm4gdGhpcy5vcmllbnRhdGlvbiA9PT0gJ3ZlcnRpY2FsJyA/ICcxcHggc29saWQgcmdiKDU4LCA1OSwgNjEpJyA6IHVuZGVmaW5lZFxuICB9XG5cbiAgQEhvc3RCaW5kaW5nKCdzdHlsZS5ib3JkZXItcmlnaHQnKVxuICBnZXQgcmlnaHRCb3JkZXIgKCkge1xuICAgIHJldHVybiB0aGlzLm9yaWVudGF0aW9uID09PSAndmVydGljYWwnID8gJzFweCBzb2xpZCByZ2IoOTYsIDk3LCAxMDEpJyA6IHVuZGVmaW5lZFxuICB9XG5cbiAgQEhvc3RCaW5kaW5nKCdzdHlsZS5ib3JkZXItdG9wJylcbiAgZ2V0IHRvcEJvcmRlciAoKSB7XG4gICAgcmV0dXJuIHRoaXMub3JpZW50YXRpb24gPT09ICdob3Jpem9udGFsJyA/ICcxcHggc29saWQgcmdiKDU4LCA1OSwgNjEpJyA6IHVuZGVmaW5lZFxuICB9XG5cbiAgQEhvc3RCaW5kaW5nKCdzdHlsZS5ib3JkZXItYm90dG9tJylcbiAgZ2V0IGJvdHRvbXRCb3JkZXIgKCkge1xuICAgIHJldHVybiB0aGlzLm9yaWVudGF0aW9uID09PSAnaG9yaXpvbnRhbCcgPyAnMXB4IHNvbGlkIHJnYig5NiwgOTcsIDEwMSknIDogdW5kZWZpbmVkXG4gIH1cbn1cbiJdfQ==