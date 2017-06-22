//
//  LMHttpHandle.h
//  Task
//
//  Created by Flame Grace on 2017/6/22.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpDownloadHandle;

@protocol HttpDownloadHandleDelegate <NSObject>

- (void)httpDownloadHandle:(HttpDownloadHandle *)handle downloadNewImage:(NSString *)imagePath;

@end

@interface HttpDownloadHandle : NSObject <HttpDownloadHandleDelegate>

@property (weak, nonatomic) id <HttpDownloadHandleDelegate> delegate;

+ (void)clear;

@end
