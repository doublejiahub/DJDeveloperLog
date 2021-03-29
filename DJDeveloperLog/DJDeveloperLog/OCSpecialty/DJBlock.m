//
//  DJBlock.m
//  DJDeveloperLog
//
//  Created by haojiajia02 on 2021/3/26.
//

/*
 block 作为回调函数好处
 1.写代码更顺畅，不用中途跑到另一个地方写回调函数，可以直接在调用函数处写后续处理代码
 2.block 作为回调函数，可以直接访问内部变量
 
 为什么用 copy
 block 默认是存储在栈上，block copy 的功能是把 block 从栈复制到堆上。
 __block 会把变量随着 block copy 到堆上，所以才能被block共享
 
 OC：返回值（^名称)(形参类型) = ^(形参类型 形参名)(函数体)
    typedef returnType(^name)(arguments);
 swift： 闭包名 = { (形参名：形参类型) -> 返回值 in }
 */



#import "DJBlock.h"
#import "DJPerson.h"

static int staticGloablA = 10;
typedef void(^block)(void);

@interface DJBlock()

@property(nonatomic,copy) block catchBlock;

@end

@implementation DJBlock

+ (void)execute {
    DJBlock *bl = [[DJBlock alloc] init];
    [bl underlineBlock];
}

- (void)catchVariable {
    int a = 10;
    self.catchBlock = ^{
        NSLog(@"intA: %d",a);
    };
    a = 20;
    self.catchBlock();
    NSLog(@"intA: %d",a);
    //基本类型捕获值 10
    
    NSString *str = @"Lily";
    self.catchBlock = ^{
        NSLog(@"str: %@",str);
    };
    str = @"Sharon";
    self.catchBlock();
    NSLog(@"str: %@",str);
    //字符串捕获值 Lily

    DJPerson *person1 = [[DJPerson alloc] init];
    __block DJPerson *person2 = [[DJPerson alloc] init];
    person1.name = @"Mike";
    person2.name = @"Sean";
    self.catchBlock = ^{
        NSLog(@"person1: %@",person1.name);
        NSLog(@"person2: %@",person2.name);
    };
    person1.name = @"Lucy";
    person2.name = @"Jane";
    self.catchBlock();
    NSLog(@"person1: %@",person1.name);
    NSLog(@"person2: %@",person2.name);
    //对象类型捕获指针
    
    static int staticA = 10;
    self.catchBlock = ^{
        NSLog(@"staticA: %d",staticA);
    };
    staticA = 20;
    self.catchBlock();
    NSLog(@"staticA: %d",staticA);
    //静态局部变量捕获指针 20
    
    self.catchBlock = ^{
        NSLog(@"staticGloablA: %d",staticGloablA);
    };
    staticGloablA = 20;
    self.catchBlock();
    NSLog(@"staticGloablA: %d",staticGloablA);
    //全局变量不捕获 20
}

- (void)underlineBlock {
    int a = 10;
    self.catchBlock = ^{
        NSLog(@"intA: %d",a);
    };
    a = 20;
    self.catchBlock();
    NSLog(@"intA: %d",a); //20
    //基本类型捕获值 10

    __block int underlineBlockA = 10;
    self.catchBlock = ^{
        NSLog(@"underlineBlockA: %d",underlineBlockA);
        underlineBlockA = 15;
        NSLog(@"underlineBlockA changed: %d",underlineBlockA);
    };
    underlineBlockA = 20;
    self.catchBlock();
    NSLog(@"underlineBlockA: %d",underlineBlockA); //15
    //加 __block 后捕获的是什么?
    
    __block NSString *str = @"Lily";
    self.catchBlock = ^{
        NSLog(@"str: %@",str);
    };
    str = @"Sharon";
    self.catchBlock();
    NSLog(@"str: %@",str);
    //字符串捕获值 10
    //__block 后捕获指针

    __block DJPerson *person1 = [[DJPerson alloc] init];
    person1.name = @"Mike";
    __block DJPerson *person2 = [[DJPerson alloc] init];
    person2.name = @"Sean";
    self.catchBlock = ^{
        NSLog(@"person1: %@",person1.name);
        NSLog(@"person2: %@",person2.name);
    };
    person1.name = @"Lucy";
    person2.name = @"Jane";
    self.catchBlock();
    NSLog(@"person1: %@",person1.name);
    NSLog(@"person2: %@",person2.name);
    //__block 后捕获指针
}



@end
