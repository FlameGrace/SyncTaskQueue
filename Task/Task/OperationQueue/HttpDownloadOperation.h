//
//  HttpDownloadOperation.h
//  Task
//
//  Created by MAC on 2018/7/6.
//  Copyright © 2018年 flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HttpOperationCompleteHandle)(NSURLResponse *response, id responseObject, NSError *error);

@interface HttpDownloadOperation : NSOperation


@property (strong, nonatomic) NSString *savePath;

@property (strong, nonatomic) NSString *url;
//详见AFNetworkingTool.h
@property (strong, nonatomic) NSString *requestType;

@property (strong, nonatomic) NSDictionary *parameters;
//HttpTask成功回调
@property (copy, nonatomic)  HttpOperationCompleteHandle completeHandle;

+ (instancetype)taskWithUrl:(NSString *)url paras:(NSDictionary *)parameters requestType:(NSString *)requestType;

@end
