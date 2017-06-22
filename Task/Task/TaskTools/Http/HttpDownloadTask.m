//
//  HttpDownloadTask.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/13.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "HttpDownloadTask.h"

@interface HttpDownloadTask()

@property (strong, nonatomic) NSURLSessionDownloadTask *download;

@end

@implementation HttpDownloadTask


- (void)start
{
    
    NSURLSessionDownloadTask *task = [AFNetworkingTool downloadUrl:self.url requestParameters:self.parameters requestType:self.requestType progress:nil savePath:self.savePath completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if(self.completeHandle)
        {
            self.completeHandle(response, responseObject, error);
        }
        
        [self taskFinish:self error:error needRetry:NO];
    }];
    self.download = task;
}


- (void)cancel
{
    [super cancel];
    //删除已下载的文件
    [self.download cancel];
}


@end
