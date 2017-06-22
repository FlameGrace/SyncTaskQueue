//
//  HttpKeyShareDownloadTask.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/19.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "HttpDownloadTask_NetWorkErrorRetry.h"

@implementation HttpDownloadTask_NetWorkErrorRetry

- (void)taskFinish:(STTask *)task error:(NSError *)error needRetry:(BOOL)needRetry
{
    //如果错误是因网络原因引起，则判断文件需要再次下载,参见NSURLErrorDomain
    if(error&&([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable||error.code == -1009))
    {
        needRetry = YES;
    }
    [super taskFinish:task error:error needRetry:needRetry];
    
}

@end
