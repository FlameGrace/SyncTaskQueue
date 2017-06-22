//
//  AFNetworkingTool.m
//  flamegrace@hotmail.com
//
//  Created by 周浩冉 on 17/3/6.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "AFNetworkingTool.h"
#import "AFNetworking.h"

@implementation AFNetworkingTool

static AFURLSessionManager *staticSessionManager;
+ (AFURLSessionManager*)theAFURLSessionManager {
    if (!staticSessionManager) {
        staticSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        ((AFJSONResponseSerializer*)staticSessionManager.responseSerializer).acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
    }
    return staticSessionManager;
}


+ (NSURLSessionDataTask *)requestUrl:(NSString*)url
 requestParameters:(NSDictionary*)dic
       requestType:(NSString*)type
           timeout:(NSTimeInterval)timeout
 completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler  {
     NSLog(@"HTTP请求：URL:%@，参数：%@，类型：%@",url,dic,type);
     NSURLSessionDataTask *task = nil;
    if ([AFNetworkReachabilityManager sharedManager].isReachableViaWiFi ||
        [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN) {
        // 状态栏显示网络加载样式
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSMutableURLRequest *request = nil;
        if([type isEqualToString:RequestType_POST])
        {
            request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
            request.HTTPMethod = RequestType_POST;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:data];
        }
        else
        {
            request = [[AFHTTPRequestSerializer serializer] requestWithMethod:type URLString:url parameters:dic error:nil];
        }
        [request setTimeoutInterval:timeout];
        
        void (^dataTaskHandle)(NSURLResponse *response, id responseObject, NSError *error) = ^(NSURLResponse *response, id responseObject, NSError *error) {
            
            // 状态栏隐藏网络加载样式
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            completionHandler(response,responseObject,error);
        };
        
        task = [[self theAFURLSessionManager] dataTaskWithRequest:request
                                                                               completionHandler:dataTaskHandle];
        // 开始请求
        NSLog(@"HTTP请求：网络环境允许，开始请求。");
        [task resume];
    } else {
        completionHandler(NULL,NULL,[NSError errorWithDomain:NSStringFromClass(self)
                                                        code:NSURLErrorNotConnectedToInternet
                                                    userInfo:@{@"errorKey":@"Network Not Reachable"}]);
        NSLog(@"HTTP请求：URL:%@，参数：%@，类型：%@。网络不可用，失败。",url,dic,type);
    }
    return task;
}



+ (NSURLSessionDataTask *)requestUrl:(NSString*)url
 requestParameters:(NSDictionary*)dic
       requestType:(NSString*)type
 completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    return [self requestUrl:url requestParameters:dic requestType:type timeout:0 completionHandler:completionHandler];
}


+ (NSURLSessionDownloadTask *)downloadUrl:(NSString*)url
                        requestParameters:(NSDictionary*)dic
                              requestType:(NSString*)type
                                 progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                 savePath:(NSString *)savePath
                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSURLSessionDownloadTask *task = nil;
    if ([AFNetworkReachabilityManager sharedManager].isReachableViaWiFi ||
        [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN) {
        // 状态栏显示网络加载样式
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]
                                        requestWithMethod:type
                                        URLString:url
                                        parameters:dic
                                        error:nil];
        task = [[self theAFURLSessionManager] downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            if (savePath.length==0) {
                return NULL;
            }
            NSURL *URL = [NSURL fileURLWithPath:savePath];
            return URL;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            completionHandler(response,filePath,error);
        }];
         NSLog(@"下载接口：%@。",request.URL);
        [task resume];
    } else {
         NSLog(@"下载接口错误，Error：%@。",@"网络不允许");
        completionHandler(NULL,NULL,[NSError errorWithDomain:NSStringFromClass(self)
                                                        code:NSURLErrorNotConnectedToInternet
                                                    userInfo:@{@"errorKey":@"Network Not Reachable"}]);
    }
    return task;
}

+ (void)printNetworkingResponseDataInError:(NSError *)error
{
    NSError *underlyingError = error.userInfo[@"NSUnderlyingError"];
    NSData *reponseData = underlyingError.userInfo[@"com.alamofire.serialization.response.error.data"];
    NSString *responseString = [[NSString alloc]initWithData:reponseData encoding:NSUTF8StringEncoding];
    NSLog(@"网络错误返回数据：%@",responseString);
}

@end
