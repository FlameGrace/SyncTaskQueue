//
//  ImageDownloadHandle.m
//  Task
//
//  Created by MAC on 2018/7/6.
//  Copyright © 2018年 flamegrace. All rights reserved.
//

#import "ImageDownloadHandle.h"
#import "HttpDownloadOperation.h"
#define RandomImageHttpRequestUrl (@"https://unsplash.it/1920/1080/?random")
#import "DownloadOperationQueue.h"

@interface ImageDownloadHandle()
{
    int downloadHandle;
}

@property (strong, nonatomic) DownloadOperationQueue *taskQueue;

@end

@implementation ImageDownloadHandle
@synthesize delegate = _delegate;


- (instancetype)init
{
    if(self = [super init])
    {
        [[self class] create];
        self.taskQueue = [[DownloadOperationQueue alloc]init];
        self.taskQueue.maxConcurrentOperationCount = 1;
        [self observeNotifications];
        [self addQueryTask];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.taskQueue cancelAllOperations];
    self.taskQueue = nil;
    NSLog(@"灰飞烟灭");
}

- (void)observeNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkStateChanged:) name:NetWorkStateChangedNotificationName object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationDidBecomeActive:)
//                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationDidEnterBackground:)
//                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)netWorkStateChanged:(NSNotification *)notification
{
    if([NetWorkStateManager shareManager].netWorkState != NetWorkStateUnknown ||
       [NetWorkStateManager shareManager].netWorkState !=NetWorkStateNotReachable)
    {
        self.taskQueue.suspended = NO;
        [self addQueryTask];
    }
    if([NetWorkStateManager shareManager].netWorkState ==NetWorkStateNotReachable)
    {
        self.taskQueue.suspended = YES;
    }
}


- (void)downloadHandle:(id<DownLoadHandleProtocol>)handle downloadNewImage:(NSString *)imagePath
{
    NSLog(@"现在还有%lu个任务",(unsigned long)self.taskQueue.operationCount);
    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadHandle:downloadNewImage:)])
    {
        [self.delegate downloadHandle:handle downloadNewImage:imagePath];
    }
}

- (void)query
{
    int lastDownloadHandle = downloadHandle;
    downloadHandle += 10;
    NSInteger download = downloadHandle;
    NSLog(@"添加query任务前：%d  %d。",lastDownloadHandle,downloadHandle);
    NSBlockOperation *operation = [[NSBlockOperation alloc]init];
    WeakObj(self)
    [operation addExecutionBlock:^{
        StrongObj(self)
        
        for (int i= lastDownloadHandle; i< download; i++) {
            NSString *image = RandomImageHttpRequestUrl;
            NSString *savePath = [[[self class] saveDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"dd_%d.jpg",i]];
            [self addDownloadTask:image savePath:savePath];
        }
    }];
    [self.taskQueue addOperation:operation];
}

- (void)addQueryTask
{
    @synchronized(self) {
        [self query];
    }
}

- (void)addDownloadTask:(NSString *)image savePath:(NSString *)savePath
{
    if([[NSFileManager defaultManager]fileExistsAtPath:savePath])
    {
        return;
    }
    HttpDownloadOperation *task = [HttpDownloadOperation taskWithUrl:image paras:nil requestType:RequestType_GET];
    task.name = [savePath lastPathComponent];
    task.savePath = savePath;
    WeakObj(self)
    task.completeHandle = ^(NSURLResponse *response, id responseObject, NSError *error) {
        StrongObj(self)
        if(!error)
        {
            [self downloadHandle:self downloadNewImage:savePath];
            return ;
        }
    };
    NSLog(@"添加任务：%@。",task.name);
    [self.taskQueue addOperation:task];
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
