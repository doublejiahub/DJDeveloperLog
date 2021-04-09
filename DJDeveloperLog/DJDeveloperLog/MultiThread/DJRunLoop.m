//
//  JJRunLoop.m
//  HJJLog
//
//  Created by haojiajia02 on 2021/1/22.
//

/*
RunLoop - 运行循环
作用:
1.保证程序不退出
2.负责监听事件(触摸、时钟、网络)(事件是硬件将事件转化为电信号传给系统，系统传给app。)
3.有事做事，无事休息


核心就是保证线程有事做事，无事休息，它的设计是为了节省CPU资源。底层是通过系统内核态和用户态的切换来实现的，有事件时切换到用户态(内核态可以访问系统所有资源，包括硬件，比如键盘输入；用户态只能访问自己程序的资源，所有程序都是运行在用户态的，内核态和用户态的设计就是为了限制一个程序不能访问其他程序的内存数据。)
 
RunLoop 与线程
1.一对一，runLoop 与线程的映射保存在一个 NSDictionary 中
2.app 一启动就会开启一个主线程 ，主线程的 runLoop 要一直运行，因为 runLoop 在执行完事件后就会休眠，那么就会退出 app，无法保证 app 的持续运行，所以主线程的 runLoop 默认会一直开启，内部是个 do-while 的死循环，保证 app 一直在等待事件的状态。 当 app 在后台挂起时，线程同时被挂起，runLoop 也被挂起。
3.子线程的runLoop 默认不会开启，而且启动前内部必须要有至少一个 Timer/Observer/Source，所以子线程要想保持 runLoop 常活，就需要一直有事件。
 
 RunLoopMode
 一个 runLoop 同时只能有一种 mode
 
 系统在每个runloop迭代中都加入了自动释放池Push和Pop，当RunLoop开启时，就会自动创建一个自动释放池，当RunLoop在休息之前会释放掉自动释放池的东西，然后重新创建一个新的空的自动释放池，当RunLoop被唤醒重新开始跑圈时，Timer,Source等新的事件就会放到新的自动释放池中，当RunLoop退出的时候也会被释放。
 注意：只有主线程的RunLoop会默认启动。也就意味着会自动创建自动释放池，子线程需要在线程调度方法中手动添加自动释放池。
 */

#import "DJRunLoop.h"

@implementation DJRunLoop

- (void)deep {
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
}

@end
