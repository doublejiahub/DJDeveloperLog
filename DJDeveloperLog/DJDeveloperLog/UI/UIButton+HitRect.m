//
//  UIButton+HitRect.m
//  DJDeveloperLog
//
//  Created by haojiajia02 on 2021/3/26.
//

#import "UIButton+HitRect.h"
#import <objc/runtime.h>

static const NSString *KEY_HIT_TEST_EDGE_INSETS = @"HitTestEdgeInsets";
@implementation UIButton (HitRect)
- (void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = [NSValue value:&hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS);
    if(value) {
        UIEdgeInsets edgeInsets; [value getValue:&edgeInsets]; return edgeInsets;
    }else {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(UIEdgeInsetsEqualToEdgeInsets(self.hitTestEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

/*
 添加属性需要用关联对象实现，
 所有对象的关联内容都放在同一个全局容器哈希表中:AssociationsHashMap,
 由 AssociationsManager 统一管理。
 
 关键策略是一个enum值
 OBJC_ASSOCIATION_ASSIGN = 0,      <指定一个弱引用关联的对象>
 OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,<指定一个强引用关联的对象>
 OBJC_ASSOCIATION_COPY_NONATOMIC = 3,  <指定相关的对象复制>
 OBJC_ASSOCIATION_RETAIN = 01401,      <指定强参考>
 OBJC_ASSOCIATION_COPY = 01403    <指定相关的对象复制>

 为什么没有weak?
 
 */

@end
