//
//  LMHttpHandle.h
//  Task
//
//  Created by Flame Grace on 2017/6/22.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownLoadHandleProtocol.h"

@interface HttpDownloadHandle : NSObject <DownLoadHandleProtocol,DownloadHandleDelegate>

@end
