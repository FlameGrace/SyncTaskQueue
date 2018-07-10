//
//  HttpDownloadOperation.m
//  Task
//
//  Created by MAC on 2018/7/6.
//  Copyright © 2018年 flamegrace. All rights reserved.
//

#import "HttpDownloadOperation.h"
#import "RetryTimeoutHandle.h"

@interface HttpDownloadOperation()

@property (strong, nonatomic) NSCondition *condition;
@property (strong, nonatomic) RetryTimeoutHandle *retry;

@end

@implementation HttpDownloadOperation

- (void)dealloc
{
    NSLog(@"释放任务：%@",self.name);
}

- (instancetype)init
{
    if(self = [super init])
    {
        self.condition = [[NSCondition alloc]init];
        self.retry = [[RetryTimeoutHandle alloc]init];
        self.retry.retryCount = 0;
    }
    return self;
}

+ (instancetype)taskWithUrl:(NSString *)url paras:(NSDictionary *)parameters requestType:(NSString *)requestType
{
    HttpDownloadOperation *task = [[self alloc]init];
    task.url = url;
    task.parameters = parameters;
    task.requestType = requestType;
    return task;
}

- (void)main
{
    NSLog(@"开始执行任务：%@",self.name);
    WeakObj(self)
    self.retry.retryBlock = ^{
        StrongObj(self)
        [self request];
    };
    [self.retry start];
    [self.condition lock];
    [self.condition wait];
    [self.condition unlock];
}



- (void)request
{
    WeakObj(self)
    [AFNetworkingTool downloadUrl:self.url requestParameters:self.parameters requestType:self.requestType progress:nil savePath:self.savePath completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        StrongObj(self)
        NSLog(@"执行任务完成：%@，%@",self.name,error);
        if(!error || error.code != -1009)
        {
            [self.retry stop];
            if(self.completeHandle)
            {
                self.completeHandle(response, responseObject, error);
            }
            [self.condition lock];
            [self.condition signal];
            [self.condition unlock];
        }
    }];
    
}

@end
