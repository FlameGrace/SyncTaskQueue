//
//  NetWorkStateManager.h
//  
//
//  Created by Flame Grace on 16/9/19.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

#define NetWorkStateChangedNotificationName @"NetWorkStateChanged"



typedef NS_ENUM(NSInteger, NetWorkState) {
    NetWorkStateUnknown          = -1,//未识别的网络
    NetWorkStateNotReachable     = 0,//不可达的网络
    NetWorkStateReachableViaWiFi = 1,//wifi网络
    NetWorkStateReachableViaWwan = 2,//蜂窝网络
    
};

@interface NetWorkStateManager : NSObject


+ (instancetype)shareManager;

//当前网络状态
@property (readonly, nonatomic)  NetWorkState netWorkState;



@end
