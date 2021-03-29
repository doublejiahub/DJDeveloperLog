//
//  DJRuntime.m
//  HJJLog
//
//  Created by haojiajia02 on 2021/1/23.
//

#import "DJRuntime.h"
#import "DJPerson.h"
#import <objc/runtime.h>

/*
 1.类对象与元类对象
 2.消息传递
 3.方法缓存
 4.消息转发
 5.方法交换
 */

/*
 ********************************* runtime 数据结构 *******************************
 typedef struct objc_object *id; // id 在C底层就是 objc_object 结构体
 struct objc_object {
     Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
 };
 isa 指针包含 isa_t共用体、isa操作的方法、弱引用相关方法、关联对象相关方法、内存管理相关方法（autoreleasepool）
 isa 指针的含义：isa 分为指针型、非指针型, isa 的值/值的部分代表 class 的地址
 isa 指针的指向：
 对象的 isa 指针指向类对象 Class, 调用实例方法,实际是通过 isa 指针到类对象中进行方法查找
 类对象的 isa 指针指向元类对象 MetaClass, 调用类方法,实际是通过类对象的 isa 指针到元类对象进行方法查找

 typedef struct objc_class *Class; //Class 在C底层就是 objc_class 结构体，继承自 objc_object, 称之为类对象
 struct objc_class {
     Class _Nonnull isa;                         // 指向元类
     Class _Nullable super_class;                // 父类
     const char * _Nonnull name;                 // 类名
     struct objc_method_list * _Nullable * _Nullable methodLists;  // 方法定义的链表
                                                                   // 类对象存储实例方法列表，元类对象存储类方法列表
     struct objc_cache * _Nonnull cache;                           // 方法缓存
     struct objc_ivar_list * _Nullable ivars;           // 该类的成员变量链表
     struct objc_protocol_list * _Nullable protocols;   // 协议链表
     .......
 } ;
 
 class_data_bits_t bits 存放着类定义的成员变量, 属性, 方法
 
 cache_t
 用于快速查找方法执行函数
 可扩展的哈希表结构,cache_t 是个 bucket_t数组, 每个 bucket_t 都是哈希表 key: IMP，key 就是 selector ,实际是个选择器 SEL; IMP 是个函数指针
 cache_t 是局部性原理的应用, 局部性原理即调用频率高的放到缓存中
 
 class_data_bits_t
 是对 class_rw_t 的封装
 class_rw_t 代表了类相关的读写信息, 对 class_ro_t 的封装
 class_rw_t 包含
    class_ro_t
    protocols
    properties
    methods（是 method_t 的二维数组，所有分类是个数组，每个分类中是 method_t 数组）
    分类中添加的协议、属性、方法就是加到了后三者中
 class_ro_t 包含
    name： NSClassFromString 就是访问的 name
    ivars： 类的成员变量
    protocols
    properties
    methodList: 原始定义的方法（是 method_t 的一维数组）

 method_t
 函数四要素：名称、返回值、参数、函数体
 struct method_t {
    SEL name；
    const char* types: 返回值、参数
    IMP imp;
 }

 
 *********************************  类对象与元类对象 *******************************
 类对象与元类对象区别：
 元类对象即是描述类对象的类，每个类都有自己的元类，也就是结构体objc_class中isa指向的类。
 类对象存储实例方法列表，元类对象存储类方法列表
 
 类通过 superClass 找到父类，NSObject 的 superClass 是 nil
 实例通过 isa 指针找到自己的类对象，找到实例方法列表
 类对象通过 isa 指针找到元类对象，访问类方法
 
 如果调用的一个类方法没有对应的实现，但是有同名的实例方法的实现，会不会崩溃？会不会调用？
 不会崩溃，会调用
 

 *********************************  消息传递机制  *******************************
 [self class] [super class] 的 receiver 都是当前对象
 [phone class] 先找到它的类 Phone，在 Phone 类的方法列表中查找 class 方法
 Phone 中没有，去 superClass Mobile 中查找，直到找到 NSObject 中，NSObject中有，调用实现
 [super class] 的 receiver 还是当前 phone 实例
 [super class] 从 Mobile 的实例方法开始查找，直到找到 NSObject 中，NSObject中有，调用实现
 
 
 *********************************  消息转发流程  *******************************
 + (BOOL)resolveInstanceMethod:(SEL)sel
 - (id)forwardingTargetForSelector:(SEL)aSelector //返回转发目标
 - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector //返回方法签名，接下来就会调用 forwardInvocation
 - (void)forwardInvocation:(NSInvocation *)anInvocation

 */

/*
 load 是只要类所在文件被引用就会被调用，如果类没有被引用进项目，就不会有load调用
 initialize是在类或者其子类的第一个方法被调用前调用，但即使类文件被引用进来，但是没有使用，那么initialize不会被调用。
 */

@interface DJRuntime()

@end

@implementation DJRuntime

#pragma mark - 消息传递机制
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(test)) {
        
        NSLog(@"resolveInstanceMethod:");
        return NO;
    }
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == @selector(test)) {
        NSLog(@"forwardingTargetForSelector:");
        return nil;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    
    if (aSelector == @selector(test)) {
        NSLog(@"methodSignatureForSelector:");
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"forwardInvocation:");
}

#pragma mark - 元类、根元类
+ (void)metaClass {
    Class pClass = object_getClass([DJPerson alloc]);
    //JJPerson 根元类
    Class pMetaClass = object_getClass(DJPerson.class);
    
    NSLog(@"pClass: %p \n",pClass);
    NSLog(@"pMetaClass: %p",pMetaClass);
    
}

#pragma mark - 获取方法列表
- (NSString *)getClassNameList {
    Class cls = object_getClass(self);
    unsigned int count;
    // 获取方法数组
    Method *methodList = class_copyMethodList(cls, &count);
    // 存储方法名
    NSMutableString *methodNames = [NSMutableString new];
    // 遍历所有方法
    for (int i=0; i<count; i++) {
        // 获得方法
        Method method = methodList[i];
        // 获得方法名
        NSString *methodName = NSStringFromSelector(method_getName(method));
        // 拼接方法名
        [methodNames appendString:methodName];
        [methodNames appendString:@", "];
    }
    // 释放
    free(methodList);
    return [methodNames copy];
}


#pragma mark - 获取成员变量和属性名
- (void)getIvarList {
    unsigned int count = 0;
    //该方法是C函数，获取所有属性
    Ivar * ivars = class_copyIvarList([self class], &count);
    NSMutableArray *ivarNames = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        //获取属性名
        const char * name = ivar_getName(ivar);
        //使用KVC直接获取相关属性的值
        [ivarNames addObject:[NSString stringWithUTF8String:name]];
        NSObject *value = [self valueForKey:[NSString stringWithUTF8String:name]];
        NSLog(@"%@的成员变量: %s %@",[self class], name, value);
    }
    NSLog(@"成员变量列表: %@",ivarNames);
    //需要释放获取到的属性
    free(ivars);
}


// 打印属性列表
- (void)getPropertyList {
    unsigned int count;
    NSMutableArray *propertyNames = [NSMutableArray array];
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        [propertyNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    NSLog(@"属性列表: %@",propertyNames);
    free(propertyList);
}


@end
