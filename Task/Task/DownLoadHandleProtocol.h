//
//  DownLoadHandleProtocol.h
//  Task
//
//  Created by MAC on 2018/7/6.
//  Copyright © 2018年 flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownLoadHandleProtocol;

@protocol DownloadHandleDelegate <NSObject>

- (void)downloadHandle:(id<DownLoadHandleProtocol>)handle downloadNewImage:(NSString *)imagePath;

@end

@protocol DownLoadHandleProtocol <NSObject>

@property (weak, nonatomic) id <DownloadHandleDelegate> delegate;

+ (void)clear;

@end
