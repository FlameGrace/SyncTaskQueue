//
//  DownloadTaskQueue.m
//  leapmotor
//
//  Created by Flame Grace on 2017/6/12.
//  Copyright © 2017年 Flame Grace. All rights reserved.
//

#import "SyncTaskQueue.h"

@interface SyncTaskQueue() <TaskFinishNotifyDelegate>

@property (strong, nonatomic) dispatch_queue_t queue;
@property (readwrite,strong, nonatomic) NSMutableArray *cacheTasks;
@property (readwrite,strong, nonatomic) NSMutableArray *unexecutedTasks;
@property (readwrite, assign, nonatomic) BOOL isExecuting;
@property (readwrite, assign, nonatomic) BOOL isPause;
@property (readwrite, strong, nonatomic) STTask *currentTask;

@end


@implementation SyncTaskQueue

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    if(self = [super init])
    {
        [self createQueueWithQueue:queue];
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self createQueueWithQueue:nil];
    }
    return self;
}

- (void)createQueueWithQueue:(dispatch_queue_t)queue
{
    if(!queue)
    {
        NSString *queueIdentifer = [NSString stringWithFormat:@"%@-%f",NSStringFromClass([self class]),[NSDate date].timeIntervalSince1970];
        queue = dispatch_queue_create([queueIdentifer UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    self.retryDuration = 5;
    self.queue = queue;
    self.cacheTasks = [[NSMutableArray alloc]init];
    self.unexecutedTasks = [[NSMutableArray alloc]init];
}

-(void)dealloc
{
    
    [self pasue];
    [self.currentTask cancel];
    self.cacheTasks = nil;
    self.unexecutedTasks = nil;
    self.queue = nil;
}



- (void)taskFinish:(STTask *)task error:(NSError *)error needRetry:(BOOL)needRetry
{
    NSTimeInterval duration = self.retryDuration;
    if(!needRetry)
    {
        duration = self.executeDuration;
        [self.unexecutedTasks removeObject:task];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, self.queue, ^{
        [weakSelf executeTask];
    });
}

- (void)restartTask
{
    if(self.isPause)
    {
        return;
    }
    if(self.isExecuting)
    {
        return;
    }
    self.isExecuting = YES;
    [self executeTask];
}

- (void)executeTask
{
    dispatch_async(self.queue, ^{
    
        if(self.isPause)
        {
            self.isExecuting = NO;
            return;
        }
        STTask * task = [self.unexecutedTasks firstObject];
        self.currentTask = task;
        
        if(!task)
        {
            self.isExecuting = NO;
            return;
        }
        
        [task start];
    });
}

- (void)removeTask:(STTask *)task
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(self.queue, ^{
            NSLog(@"移除task：%@",task.identifier);
            [self.cacheTasks removeObject:task];
            [self.unexecutedTasks removeObject:task];
        });
    });
}

- (void)addTask:(STTask *)task
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(self.queue, ^{
            if(!task)
            {
                return;
            }
            if(task.identifier&&task.identifier.length > 0 )
            {
                if(task.identifierType == TaskIdentifierInQueueUnique)
                {
                    NSArray *cacheTasks = [NSArray arrayWithArray:self.cacheTasks];
                    for (STTask *obj in cacheTasks)
                    {
                        if([obj.identifier isEqualToString:task.identifier])
                        {
                            return;
                        }
                    }
                }
                if(task.identifierType == TaskIdentifierInQueueUnexecutedUnique)
                {
                    NSArray *unexecutedTasks = [NSArray arrayWithArray:self.unexecutedTasks];
                    for (STTask *obj in unexecutedTasks)
                    {
                        if([obj.identifier isEqualToString:task.identifier])
                        {
                            return;
                        }
                    }
                }
            }
            
            task.finishHandle = self;
            [self.cacheTasks addObject:task];
            [self.unexecutedTasks addObject:task];
            [self restartTask];
        });
    });
}


- (STTask *)taskByIdentifier:(NSString *)identifier
{
    __block STTask *task = nil;
    [self.cacheTasks enumerateObjectsUsingBlock:^(STTask *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([identifier isEqualToString:obj.identifier])
        {
            *stop = YES;
            task = obj;
        }
    }];
    return task;
}

- (void)pasue
{
    self.isPause = YES;
}


- (void)resume
{
    if(!self.isPause)
    {
        return;
    }
    self.isPause = NO;
    [self restartTask];
}

@end




@implementation SyncTaskQueue(Identifier)

- (NSArray *)cacheIdentifiers
{
    NSArray *cache = [NSArray arrayWithArray:self.cacheTasks];
    NSArray *identifiers = [cache valueForKeyPath:@"identifier"];
    return identifiers;
}

- (NSArray *)unexecutedIdentifiers
{
    NSArray *unexecuted = [NSArray arrayWithArray:self.unexecutedTasks];
    NSArray *identifiers = [unexecuted valueForKeyPath:@"identifier"];
    return identifiers;
}

@end
