//
//  HttpDownloadTask.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/12.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "HttpTask.h"

@interface HttpTask()



@end


@implementation HttpTask


+ (instancetype)taskWithUrl:(NSString *)url paras:(NSDictionary *)parameters requestType:(NSString *)requestType
{
    HttpTask *task = [self task];
    task.url = url;
    task.parameters = parameters;
    task.requestType = requestType;
    return task;
}


- (void)start
{
    WeakObj(self)
    [AFNetworkingTool requestUrl:self.url requestParameters:self.parameters requestType:self.requestType completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        StrongObj(self)
        if(self.completeHandle)
        {
            self.completeHandle(response, responseObject, error);
        }
        [self taskFinish:self error:error needRetry:NO];
    }];
}

- (void)cancel
{
    [super cancel];
    self.completeHandle = nil;
}


@end
