//
//  DownloadTaskQueue.m
//  leapmotor
//
//  Created by 李嘉军 on 2017/6/12.
//  Copyright © 2017年 Leapmotor. All rights reserved.
//

#import "SyncTaskQueue.h"

@interface SyncTaskQueue() <TaskFinishNotifyDelegate>

@property (strong, nonatomic) dispatch_queue_t queue;
@property (readwrite,strong, nonatomic) NSMutableArray *cacheTasks;
@property (readwrite,strong, nonatomic) NSMutableArray *unexecutedTasks;
@property (readwrite, assign, nonatomic) BOOL isExecuting;
@property (readwrite, assign, nonatomic) BOOL isPause;
@property (readwrite, strong, nonatomic) Task *currentTask;

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



- (void)taskFinish:(Task *)task error:(NSError *)error needRetry:(BOOL)needRetry
{
    NSTimeInterval duration = self.retryDuration;
    if(!needRetry)
    {
        duration = self.executeDuration;
        [self.unexecutedTasks removeObject:task];
    }
    [self performSelector:@selector(executeTask) withObject:nil afterDelay:duration];
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
        Task * task = [self.unexecutedTasks firstObject];
        self.currentTask = task;
        
        if(!task)
        {
            self.isExecuting = NO;
            return;
        }
        
        [task start];
    });
}

- (void)removeTask:(Task *)task
{
    [self.cacheTasks removeObject:task];
    [self.unexecutedTasks removeObject:task];
}

- (void)addTask:(Task *)task
{
    if(!task)
    {
        return;
    }
    if(task.identifier&&task.identifier.length > 0 )
    {
        //检查cacheTasks是否已有此标识符的任务
        if(task.identifierType == TaskIdentifierInQueueUnique)
        {
            [self.cacheTasks enumerateObjectsUsingBlock:^(Task *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj.identifier isEqualToString:task.identifier])
                {
                    return;
                }
            }];
        }
        //检查exectuteTasks是否已有此标识符的任务
        if(task.identifierType == TaskIdentifierInQueueUnexecutedUnique)
        {
            NSArray *exectuteTasks = [NSArray arrayWithArray:self.unexecutedTasks];
            [exectuteTasks enumerateObjectsUsingBlock:^(Task *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj.identifier isEqualToString:task.identifier])
                {
                    return;
                }
            }];
        }
    }
    task.finishHandle = self;
    [self.cacheTasks addObject:task];
    [self.unexecutedTasks addObject:task];
    [self restartTask];
}


- (Task *)taskByIdentifier:(NSString *)identifier
{
    __block Task *task = nil;
    [self.cacheTasks enumerateObjectsUsingBlock:^(Task *obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
