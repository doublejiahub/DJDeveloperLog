//
//  DJGCD.m
//  DJDeveloperLog
//
//  Created by haojiajia02 on 2021/3/22.
//

#import "DJGCD.h"

@interface DJGCD()

@property(nonatomic, strong) dispatch_queue_t myQueue;

@end

@implementation DJGCD

+ (void)execute {
    DJGCD *gcd = [[DJGCD alloc] init];
    [gcd queue];
}


- (void)queue {
    NSLog(@"1 --- %@",[NSThread currentThread]); //主
    self.myQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"2 --- %@",[NSThread currentThread]); //2 并发子线程
        dispatch_sync(self.myQueue, ^{ // 3 并发子线程
            NSLog(@"3 --- %@",[NSThread currentThread]);
        });
        dispatch_async(self.myQueue, ^{ // 4 串行队列
            NSLog(@"4 --- %@",[NSThread currentThread]);
        });
        dispatch_async(self.myQueue, ^{ // 5 串行队列
            NSLog(@"5 --- %@",[NSThread currentThread]);
        });
        NSLog(@"6 --- %@",[NSThread currentThread]); //6 并发子线程
    });
    NSLog(@"7 --- %@",[NSThread currentThread]); //主
}

@end

