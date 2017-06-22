//
//  HttpKeyShareDownloadTask.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 2017/6/19.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  如果错误是因网络原因引起,则一直重试下载，若将该类添加到SyncTaskQueue中，在断网时应该暂停任务队列，防止一直重试下载

#import "HttpDownloadTask.h"

@interface HttpDownloadTask_NetWorkErrorRetry : HttpDownloadTask

@end
