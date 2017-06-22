//
//  NetWorkStateManager.m
//  
//
//  Created by Flame Grace on 16/9/19.
//  Copyright © 2016年 . All rights reserved.
//

#import "NetWorkStateManager.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"



@interface NetWorkStateManager()


@property (strong, nonatomic) Reachability *netWorkReachability;
@property (readwrite, nonatomic)  NetWorkState netWorkState;


@end


@implementation NetWorkStateManager

static NetWorkStateManager *shareManager = nil;
static NSString *hostName = @"www.apple.com";


+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[NetWorkStateManager alloc]init];
    });
    return shareManager;
}

- (id)init
{
    if(self = [super init])
    {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.netWorkReachability = [Reachability reachabilityWithHostName:hostName];
        [self getCurrentNetWorkState];
        [self.netWorkReachability startNotifier];
    }
    return self;
}



- (void)reachabilityChanged:(NSNotification *)notification
{
    [self getCurrentNetWorkState];
    
}

//获取当前网络状态
- (void)getCurrentNetWorkState
{
    
    NetWorkState lastNetWorkState = self.netWorkState;
    
    NetworkStatus internetStatus = [_netWorkReachability currentReachabilityStatus];
    NetWorkState netWorkState;
    
    switch (internetStatus) {
        case ReachableViaWiFi:
            netWorkState = NetWorkStateReachableViaWiFi;
            break;
            
        case ReachableViaWWAN:
            netWorkState = NetWorkStateReachableViaWwan;
            break;
            
        case NotReachable:
            netWorkState = NetWorkStateNotReachable;
            break;
        default:
            netWorkState = NetWorkStateUnknown;
            break;
    }
    
    self.netWorkState = netWorkState;
    
    if(lastNetWorkState != self.netWorkState)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:NetWorkStateChangedNotificationName object:nil];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
