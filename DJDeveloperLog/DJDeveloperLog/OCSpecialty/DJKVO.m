//
//  DJKVO.m
//  DJDeveloperLog
//
//  Created by haojiajia02 on 2021/3/29.
//

/*
 setValueForKey
 1. 看访问器方法是否存在
 setAge - (void)setAge:(int)age
 _setAge - (void)_setAge:(int)age
 2. 看成员变量是否存在（可通过 accessInstanceVariablesDirectly 返回 NO 拦截）
 int _age
 int _isAge
 int age
 int isAge
 3. 看属性是否存在
 都没有，就会调用 setValue:(id)value forUndefinedKey:(NSString *)key 抛出异常
 valueForKey

 看访问器方法是否存在
 age
 isAge
 _age
 _isAge
 valueForUndefinedKey
 */

#import "DJKVO.h"
#import <objc/runtime.h>

@interface DJKVO()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int value;

@end

@implementation DJKVO

- (instancetype)init {
    if (self = [super init]) {
        [self uses];
    }
    return  self;
}

- (void)increase {
    //直接为成员变量赋值
    [self willChangeValueForKey:@"value"];
    _value += 1;
    [self didChangeValueForKey:@"value"];
}


#pragma mark - 应用场景
- (void)uses {
    self.name = @"kvo_name";
    NSLog(@"监听前: %@", object_getClass(self));

    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:@"name" options:options context:@"123"];
    self.name = @"kvo_newName";
    NSLog(@"监听后: %@", object_getClass(self));
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"监听到%@的%@属性值改变了 change: %@ context: %@", object, keyPath, change, context);
}


@end
