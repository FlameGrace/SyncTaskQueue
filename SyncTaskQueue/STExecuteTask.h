//
//  SimpleTask.h
//  Task
//
//  Created by Flame Grace on 2017/6/22.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "STTask.h"

typedef NSError *(^ExecuteTaskBlock)(void);

@interface STExecuteTask : STTask

@property (copy, nonatomic) ExecuteTaskBlock execute;



@end
