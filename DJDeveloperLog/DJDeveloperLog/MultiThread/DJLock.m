//
//  DJLock.m
//  HJJLog
//
//  Created by haojiajia02 on 2021/2/15.
//

/*
 常用的:
 @synchroniced 创建单例对象, 保证多线程环境下创建对象是单一的
 NSLock
 dispatch_semaphore_t 信号量

 不常用的:
 atomic 只保证赋值操作的线程安全性, 不保证使用操作的线程安全
 NSRecursiveLock 递归锁, 解决递归方法在多线程中的调用问题
 OSSpinLock 自旋锁, 循环等待询问, 不释放当前资源(一般的锁在第一次获取到后,后续线程是获取不到的,它会释放它当前的资源, OSSpinLock 不能获得锁,就会一直轮询,直到获得锁,类似while循环)用于轻量级数据访问, 引用计数器 +1,-1
 */

#import "DJLock.h"
#include <os/lock.h>

@interface DJLock()
@property(nonatomic, strong) NSMutableArray *array;
@property(nonatomic, strong) NSLock *lock;
@end

@implementation DJLock

+ (void)execute {
    DJLock *lock = [[DJLock alloc] init];
    [lock semaphore];
}

#pragma mark semaphore
//异步并发执行异步任务，可以用dispatch_group+semaphore 初始化信号为0，执行完一个异步通过singnal释放一个wait任务
//异步串行执行异步任务，可以用dispatch_semaphore 初始化信号为1，顺序执行任务，每个任务都加锁，执行任务消耗锁，顺延任务等待，执行完一个任务，singnal，然后下一个任务开锁顺序执行
// signal: +1
// wait: 信号量为 0 时等待,阻塞线程; 信号量 >1, 就会 -1 继续往下执行
- (void)semaphore {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t queue = dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"执行任务一");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络任务一");
            dispatch_semaphore_signal(semaphore);
        });
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"执行任务二");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络任务二");
            dispatch_semaphore_signal(semaphore);
        });
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"执行任务三");
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"执行完成");
        dispatch_semaphore_signal(semaphore);
    });
}

#pragma mark synchronized
//线程锁: 确保同时只有一条线程在执行
- (void)synchronized {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized (self) {
            NSLog(@"1");
            sleep(2);
            NSLog(@"1 ok");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized (self) {
            NSLog(@"2");
            sleep(2);
            NSLog(@"2 ok");
        }
    });
}


#pragma mark atomic
- (void)atomic {
    self.array = [NSMutableArray array]; //✅ atomic 保证赋值操作的线程安全
    [self.array addObject: @"atomic"]; //❌ atomic 不保证使用操作的线程安全
}

@end
