//
//  HttpDownloadTask.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/12.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  主导Http请求的任务

#import "STTask.h"

typedef void(^HttpTaskCompleteHandle)(NSURLResponse *response, id responseObject, NSError *error);

@interface HttpTask : STTask

@property (strong, nonatomic) NSString *url;
//详见AFNetworkingTool.h
@property (strong, nonatomic) NSString *requestType;

@property (strong, nonatomic) NSDictionary *parameters;
//HttpTask成功回调
@property (copy, nonatomic)  HttpTaskCompleteHandle completeHandle;

+ (instancetype)taskWithUrl:(NSString *)url paras:(NSDictionary *)parameters requestType:(NSString *)requestType;

@end
