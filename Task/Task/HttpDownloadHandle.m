//
//  LMHttpHandle.m
//  Task
//
//  Created by Flame Grace on 2017/6/22.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "HttpDownloadHandle.h"
#import "SyncTaskQueue.h"
#import "STExecuteTask.h"
#import "SimpleHttpDownloadTask.h"
#define RandomImageHttpRequestUrl (@"https://unsplash.it/1920/1080/?random")

@interface HttpDownloadHandle()
{
    int downloadHandle;
}

@property (strong, nonatomic) SyncTaskQueue *taskQueue;


@end


@implementation HttpDownloadHandle

- (instancetype)init
{
    if(self = [super init])
    {
        [[self class] create];
        self.taskQueue = [[SyncTaskQueue alloc]init];
        [self observeNotifications];
        [self addQueryTask];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.taskQueue = nil;
}

- (void)observeNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkStateChanged:) name:NetWorkStateChangedNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)netWorkStateChanged:(NSNotification *)notification
{
    if([NetWorkStateManager shareManager].netWorkState != NetWorkStateUnknown ||
       [NetWorkStateManager shareManager].netWorkState !=NetWorkStateNotReachable)
    {
        [self.taskQueue resume];
        [self addQueryTask];
    }
    if([NetWorkStateManager shareManager].netWorkState ==NetWorkStateNotReachable)
    {
        [self.taskQueue pasue];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.taskQueue resume];
    [self addQueryTask];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self.taskQueue pasue];
}


- (void)httpDownloadHandle:(HttpDownloadHandle *)handle downloadNewImage:(NSString *)imagePath
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(httpDownloadHandle:downloadNewImage:)])
    {
        [self.delegate httpDownloadHandle:handle downloadNewImage:imagePath];
    }
}

- (void)addQueryTask
{
    
    STExecuteTask *query = [STExecuteTask task];
    query.identifierType = TaskIdentifierInQueueUnexecutedUnique;
    query.identifier = @"HttpDownloadHandleQuery";
    WeakObj(self)
    query.execute = ^NSError *{
        
        StrongObj(self)
        int lastDownloadHandle = downloadHandle;
        downloadHandle += 10;
        if(downloadHandle == 100)
        {
            downloadHandle = 0;
        }
        for (int i= lastDownloadHandle; i<downloadHandle; i++) {
            NSString *image = RandomImageHttpRequestUrl;
            NSString *savePath = [[[self class] saveDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"dd_%d.jpg",i]];
            [self.taskQueue addTask:[self addDownloadTask:image savePath:savePath]];
        }
        return nil;
    };
    [self.taskQueue addTask:query];
}



- (SimpleHttpDownloadTask *)addDownloadTask:(NSString *)image savePath:(NSString *)savePath
{
    if([[NSFileManager defaultManager]fileExistsAtPath:savePath])
    {
        return nil;
    }
    SimpleHttpDownloadTask *task = [SimpleHttpDownloadTask task];
    task.identifierType = TaskIdentifierInQueueUnique;
    task.identifier = [savePath lastPathComponent];
    task.url = image;
    task.savePath = savePath;
    task.requestType = RequestType_GET;
    task.parameters = nil;
    WeakObj(self)
    
    task.completeHandle = ^(NSURLResponse *response, id responseObject, NSError *error) {
        StrongObj(self)
        if(!error)
        {
            [self httpDownloadHandle:self downloadNewImage:savePath];
            return ;
        }
    };
    return task;
}

+ (NSString *)saveDir
{
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"dImage"];
}

+ (void)clear
{
    [[NSFileManager defaultManager]removeItemAtPath:[self saveDir] error:nil];
    [self create];
}

+ (void)create
{
    //  在Documents目录下创建一个名为LaunchImage的文件夹
    NSString *path = [self saveDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir))
        
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
}

@end
