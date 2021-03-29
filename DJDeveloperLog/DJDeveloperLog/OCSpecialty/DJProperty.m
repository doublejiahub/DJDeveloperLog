//
//  DJProperty.m
//  DJDeveloperLog
//
//  Created by haojiajia02 on 2021/3/29.
//

/*
 atomic 保证“赋值和获取”是线程安全的(setter 和 getter 加了锁),但不保证“操作和访问”是线程安全的，比如数组的添加和移除

 strong\retain  引用计数器 +1 |
 weak           引用计数器不变 | 计数器为 0 时指针自动置为 nil
 assign         引用计数器不变
 (mutable)copy  引用计数器 +1, 深拷贝原对象+1, 浅拷贝新对象+1
 
 为什么 block 用 copy?
 ARC 下用 strong 也可以,因为系统做了 block 的 copy 操作
 */


#import "DJProperty.h"

@interface DJProperty()
//成员变量
{
    @public NSString *name; //@public公开的，可以被在任何地方访问。
    @protected NSString *age; //@protected是受保护的，只能在本类及其子类中访问，在{}声明的变量默认是@protected
    @private int idCardNumber;//@private是私有的，只能在本类访问
    //如果成员变量的类型是一个类, 就称为实例变量,比如name就是实例变量, idCardNumber则不是
}

@end

@implementation DJProperty

@end
