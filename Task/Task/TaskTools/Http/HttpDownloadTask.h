//
//  HttpDownloadTask.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/13.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  主导Http下载的任务

#import "HttpTask.h"

@interface HttpDownloadTask : HttpTask

@property (strong, nonatomic) NSString *savePath;

@end
