//
//  DJGCD.m
//  HJJLog
//
//  Created by haojiajia02 on 2021/1/24.
//

/*
 任务: GCD 中的 block
 队列: "存放任务"的线性表, 遵循 FIFO (先进先出) 原则, 线程从队列中取任务
 
 同步异步区别在于"线程", 是否阻塞当前线程/是否切换线程/决定 block 是在主线程还是子线程执行
 串行并发区别在于"任务", 任务是否按序执行
 串行队列: 执行完一个任务, GCD 才会取下一个任务
 并发队列: GCD 取完一个任务,会立即取下一个任务放到另一个线程
 
 串行队列同步执行: 当前线程按序执行
 串行队列异步执行: 切换线程按序执行
 并发队列同步执行: 当前线程按序执行
 并发队列异步执行: 多个线程无序执行
 
 串行队列异步执行,多个异步任务,串行队列决定了必定是按序执行, 即使开辟了多个线程,任务也是一个一个执行,所以没有必要开辟多个线程
 并发队列只有碰到异步,才能开线程多个任务同时执行
 串行队列同步 = 并发队列同步
 线程所占内存: 主线程(1M),子线程(512KB), 线程越多,cpu 在线程之前的调度效率变慢;多线程是为了提高用户体验, 太多时执行效率也会变慢,所以多线程 3-6 条最好
 */

#import "DJGCD.h"

@interface DJGCD()

@property(nonatomic, strong) dispatch_queue_t myQueue;

@end


@implementation DJGCD

+ (void)execute {
    DJGCD *gcd = [[DJGCD alloc] init];
//    [gcd serialSync];
//    [gcd serialAsync];
//    [gcd concurrentSync];
//    [gcd concurrentAsync];
//    [gcd performSelector];
//    [gcd mainAsnyc];
    [gcd barrierAsync];
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


#pragma mark 执行完 A,B,C 再执行 D
//异步并发执行异步任务，可以用dispa tch_group+semaphore 初始化信号为0，执行完一个异步通过singnal释放一个wait任务
//异步串行执行异步任务，可以用dispatch_semaphore 初始化信号为1，顺序执行任务，每个任务都加锁，执行任务消耗锁，顺延任务等待，执行完一个任务，singnal，然后下一个任务开锁顺序执行
// signal: +1
// wait: 信号量为 0 时等待,阻塞线程; 信号量 >1, 就会 -1 继续往下执行
- (void)semaphore {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_async(group, queue, ^{ //block1
        NSLog(@"同步任务A");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络异步任务一");
            //网络任务执行完毕, 信号量+1, 不再阻塞当前线程, block1 执行完毕
            dispatch_semaphore_signal(semaphore);
        });
        //网络任务不执行完时,一直等待, 阻塞当前线程, block1 没执行完
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务B");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络异步任务二");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务C");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务D");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络异步任务四");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"任务完成执行");
    });
}


- (void)groupEnter {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务A");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络异步任务一");
            dispatch_group_leave(group);
        });
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        
        NSLog(@"同步任务B");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络异步任务二");
            dispatch_group_leave(group);
        });
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务C");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        
        NSLog(@"同步任务D");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络异步任务四");
            dispatch_group_leave(group);
        });
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"任务完成执行");
    });

}

- (void)simulateNetwork {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务A");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"网络异步任务AA");
        });
        //因为并发队列里面的任务，只是负责打印和发送请求的操作，异步回调数据是不归队列管的，任务的执行完毕，只是Block代码块代码执行完，如果里面还包含异步任务，这里就需要通过信号量dispatch_semaphore来实现了。
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务B");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务C");
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"任务完成执行");
    });
}

- (void)operation {
    NSBlockOperation *operatioon1 = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"任务A");
    }];
    
    NSBlockOperation *operatioon2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务B");
    }];
    
    NSBlockOperation *operatioon3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务C");
    }];
    
    NSBlockOperation *operatioon4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务D");
    }];
    
    [operatioon4 addDependency:operatioon1];
    [operatioon4 addDependency:operatioon2];
    [operatioon4 addDependency:operatioon3];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[operatioon1,operatioon2,operatioon3,operatioon4] waitUntilFinished:YES];
}


- (void)barrier {
    dispatch_queue_t queue = dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"任务A");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务B");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务C");
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"阻塞自定义并发队列");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务D");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务E");
    });
}


- (void)barrierAsync {
    dispatch_queue_t queue = dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"任务A");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务B");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务C");
    });
    
    dispatch_barrier_sync(queue, ^{
        NSLog(@"阻塞自定义并发队列");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务D");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务E");
    });
}


- (void)group {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务A");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务B");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步任务C");
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"任务完成执行");
    });
}


#pragma mark performSelector
- (void)performSelector {
    NSLog(@"start --- %@",[NSThread currentThread]);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //sync 时: block 在主线程执行,2会输出
    //async 时: block 在子线程执行
    dispatch_sync(globalQueue, ^{ //block
        NSLog(@"1 --- %@",[NSThread currentThread]);
        //performSelector 需要提交任务到 runloop 上面
        //performSelector 要想执行,必须是方法调用的当前线程是有 runloop 的,如果没有就会失效
        [self performSelector:@selector(performSelectorAction) withObject:nil afterDelay:0];
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}

- (void)performSelectorAction {
    NSLog(@"2 --- %@",[NSThread currentThread]);
}


#pragma mark 主队列
//主队列特点: 必须等待主线程中的任务执行完,再执行主队列中的任务
- (void)mainSync {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{//block1
        NSLog(@"1");
    });
    NSLog(@"end");
    //mainQueueSync 和 block1 相互等待
}

- (void)mainAsnyc {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        NSLog(@"1");
    });
    NSLog(@"end");
}


#pragma mark 并发队列嵌套
- (void)concurrentSyncSync {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"start --- %@",[NSThread currentThread]);
    //sync 决定了 block1 在主线程执行
    //并发队列碰到同步和串行队列没有区别, 按序执行 1,2,3,end
    dispatch_sync(globalQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_sync(globalQueue, ^{
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}

- (void)concurrentSyncAsync {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"start --- %@",[NSThread currentThread]);
    //sync 决定了 block1 在主线程执行
    //并发队列碰到同步和串行队列没有区别, 按序执行 block1 执行完后再执行 end
    // async 决定了 block2 在子线程执行,不阻塞主线程, 1,3,2,end
    dispatch_sync(globalQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_async(globalQueue, ^{ //block2
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}

- (void)concurrentAsyncSync {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"start --- %@",[NSThread currentThread]);
    //async 决定了 block1 在子线程执行, 不阻塞当前线程, 先 end 再 1
    //并发队列决定了 globalQueue 第一个任务不执行完也会执行第二个, 所以 block1 还没完成时就可以执行 block2 , 如果是串行队列, block1,2 就死锁了
    dispatch_async(globalQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_sync(globalQueue, ^{ //block2
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}

- (void)concurrentAsyncAsync {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"start --- %@",[NSThread currentThread]);
    dispatch_async(globalQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_async(globalQueue, ^{ //block2
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}


#pragma mark 串行队列嵌套
- (void)serialSyncSync {
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"start --- %@",[NSThread currentThread]);
    //sync 决定任务在主线程执行
    //串行队列 决定了按序执行
    //block1 加入到主线程中,不执行完不会走 block2, 但是 2 是 1 的一部分, 2 不执行, 1 永远执行不完, 所以 block1,2 相互等待造成死锁, 报错 EXC_BAD_INSTRUCTION
    dispatch_sync(serialQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_sync(serialQueue, ^{ //block2
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}

- (void)serialSyncAsync {
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"start --- %@",[NSThread currentThread]);
    //sync 决定 block1 在主线程执行
    //串行队列 决定了按序执行, 肯定先 1,3 再 end
    //async 决定了 block2 在子线程执行, 2 的顺序不定 ❌ 2 一定是在 1,3,end 后面,为什么?
    dispatch_sync(serialQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_async(serialQueue, ^{ //block2
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        sleep(2);
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}

- (void)serialAsyncSync {
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"start --- %@",[NSThread currentThread]);
    //async 决定 block1 在子线程执行, 而 end 在主线程, 肯定是 start, end
    //串行队列 决定了按序执行, 肯定是 1,3
    //sync 决定了 block2 在当前子线程执行,会阻塞当前前程, 肯定是 2,3
    // start, end, 1, 2, 3  ❌  结果是死锁了
    // block2 的 sync 需要等待 block1 执行,但是 2 是 1 的一部分 ✅
    dispatch_async(serialQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_sync(serialQueue, ^{ //block2
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}

- (void)serialAsyncAsync {
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"start --- %@",[NSThread currentThread]);
    //async 决定 block1 在子线程执行, 而 end 在主线程, 肯定是 start, end
    //串行队列 决定了按序执行, 肯定是 1,3
    //async 决定了 block2 在当前子线程执行,不阻塞当前子前程, 执行完 block1 后再执行 block2, 先 1,3 再 2
    dispatch_async(serialQueue, ^{ //block1
        NSLog(@"1 --- %@",[NSThread currentThread]);
        dispatch_async(serialQueue, ^{ //block2
            NSLog(@"2 --- %@",[NSThread currentThread]);
        });
        NSLog(@"3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"end --- %@",[NSThread currentThread]);
}



#pragma mark 基础操作
- (void)serialSync {
    NSLog(@"****************************** serialSync ****************************************");
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"start --- %@",[NSThread currentThread]);
    for (int i=0; i<=10; i++) {
        dispatch_sync(serialQueue, ^{
            NSLog(@"%d --- %@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"end --- %@",[NSThread currentThread]);
    NSLog(@"\n");
}

- (void)serialAsync {
    NSLog(@"****************************** serialAsync ****************************************");
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"start --- %@",[NSThread currentThread]);
    for (int i=0; i<=10; i++) {
        dispatch_async(serialQueue, ^{
            NSLog(@"%d --- %@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"end --- %@",[NSThread currentThread]);
    NSLog(@"\n");
}

- (void)concurrentSync {
    NSLog(@"****************************** concurrentSync ****************************************");
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"start --- %@",[NSThread currentThread]);
    for (int i=0; i<=10; i++) {
        dispatch_sync(serialQueue, ^{
            NSLog(@"%d --- %@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"end --- %@",[NSThread currentThread]);
    NSLog(@"\n");
}

- (void)concurrentAsync {
    NSLog(@"****************************** concurrentAsync ****************************************");
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"start --- %@",[NSThread currentThread]);
    for (int i=0; i<=10; i++) {
        dispatch_async(serialQueue, ^{
            NSLog(@"%d --- %@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"end --- %@",[NSThread currentThread]);
    NSLog(@"\n");
}


@end
