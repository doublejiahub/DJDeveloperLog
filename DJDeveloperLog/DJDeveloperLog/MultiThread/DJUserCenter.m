//
//  DJUserCenter.m
//  HJJLog
//
//  Created by haojiajia02 on 2021/1/25.
//

#import "DJUserCenter.h"

@interface DJUserCenter()
{
    dispatch_queue_t concurrent_queue;
    NSMutableDictionary *userCenterDic;
}
@property(nonatomic, strong) NSMutableArray *array;
@property(nonatomic, strong) dispatch_queue_t readWriteTestQueue;
@end

@implementation DJUserCenter

+ (void)execute {
    DJUserCenter *userCenter = [[DJUserCenter alloc] init];
    [userCenter readWriteTest];
}

- (instancetype)init {
    if (self = [super init]) {
        concurrent_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
        userCenterDic = [NSMutableDictionary dictionary];
        self.readWriteTestQueue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
        self.array = [NSMutableArray array];
    }
    return  self;
}

//同步执行, 任务会放到当前线程中, 如果在子线程 A 中执行,那么 block 在 A 中执行
//异步执行, 任务会放到新的线程中, readWriteTestQueue
//串行队列, GCD 一个任务执行完毕后才会取下一个
//并发队列, GCD 会同时取多个任务放到多个线程中,前提是异步执行,这样才会开辟线程
//读读并发(保证顺序) 串行同步\异步, 并发同步
//读写互斥
//写写互斥
- (id)objectForKey:(NSString *)key {
    __block id obj;
    //同步读取指定数据
    //需要立刻返回结果,所以用同步,如果用异步的话, 会开辟另一条线程,当前线程继续往下执行其他任务了
    //并发队列, 这样 a 线程和 b 线程可以同时读取
    dispatch_sync(concurrent_queue, ^{
        obj = [userCenterDic objectForKey:key];
    });
    return obj;
}

//读写互斥 写写互斥
- (void)setObject:(id)obj forKey:(NSString *)key {
    //barrier 保证读写互斥
    //并发队列, 保证写写互斥
    dispatch_barrier_async(concurrent_queue, ^{
        [self->userCenterDic setObject:obj forKey:key];
    });
}

#pragma mark - 多读单写测试
- (void)readWriteTest {
    dispatch_queue_t queueOne = dispatch_queue_create("network_queue_one", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueOne, ^{
        [self write:@"1" sleep:3.0];
        [self read];
    });
    
    dispatch_queue_t queueTwo = dispatch_queue_create("network_queue_two", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueTwo, ^{
        [self write:@"2" sleep:1.0];
        [self read];
    });
    
    dispatch_queue_t queueThree = dispatch_queue_create("network_queue_three", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueThree, ^{
        [self read];
    });

    dispatch_queue_t queueFour = dispatch_queue_create("network_queue_four", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueFour, ^{
        [self write:@"3" sleep:0.0];
        [self read];
    });

    [self read];
}

- (void)read {
    NSString *arrStr = [self.array componentsJoinedByString:@","];
    NSLog(@"读 array: %@",arrStr);
}

- (void)write: (NSString *)str sleep:(double)time {
    [self.array addObject:str];
    NSString *arrStr = [self.array componentsJoinedByString:@","];
    NSLog(@"写入:%@ array: %@  thread:%@",str,arrStr,[NSThread currentThread]);
}



@end
