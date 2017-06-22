//
//  AFNetworkingTool.h
//  flamegrace@hotmail.com
//
//  Created by 周浩冉 on 17/3/6.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RequestType_GET (@"GET")
#define RequestType_PUT (@"PUT")
#define RequestType_POST (@"POST")
#define RequestType_HEAD (@"HEAD")
#define RequestType_DELETE (@"DELETE")

@interface AFNetworkingTool : NSObject

/**
 HTTP请求
 
 @param url URL
 @param dic 参数
 @param type 请求类型
 @param completionHandler 回调
 */
+ (NSURLSessionDataTask *)requestUrl:(NSString*)url
 requestParameters:(NSDictionary*)dic
       requestType:(NSString*)type
 completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

/**
 HTTP请求
 
 @param url URL
 @param dic 参数
 @param type 请求类型
 @param timeout 超时
 @param completionHandler 回调
 */
+ (NSURLSessionDataTask *)requestUrl:(NSString*)url
 requestParameters:(NSDictionary*)dic
       requestType:(NSString*)type
           timeout:(NSTimeInterval)timeout
 completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;



/**
 根据指定路径下载下载文件，并存储到指定目录。
 
 @param url url
 @param dic 参数字典
 @param type 请求类型：如GET，POST等
 @param downloadProgressBlock 通过此闭包获取下载进度
 @param savePath 下载文件的保存路径
 @param completionHandler 下载结果的回调
 @return NSURLSessionDownloadTask
 */
+ (NSURLSessionDownloadTask *)downloadUrl:(NSString*)url
                        requestParameters:(NSDictionary*)dic
                              requestType:(NSString*)type
                                 progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                 savePath:(NSString *)savePath
                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;


/**
 打印网络请求错误时的返回数据
 
 @param error error
 */
+ (void)printNetworkingResponseDataInError:(NSError *)error;
@end
