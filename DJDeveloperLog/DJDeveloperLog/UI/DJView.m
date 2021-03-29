//
//  DJView.m
//  DJDeveloperLog
//
//  Created by haojiajia02 on 2021/3/26.
//

#import "DJView.h"

@implementation DJView

#pragma mark - 查找 view 的 viewController
- (UIViewController *)currentController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

#pragma mark - 超出父视图坐标范围的子视图也能响应事件（tabBar 中间凸起）
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
      if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint subviewPoint = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, subviewPoint)) {
                if ([subView isKindOfClass:[UIButton class]]) {
                     view = subView;
                  }
              }
          }
      }
     return view;
}


@end
