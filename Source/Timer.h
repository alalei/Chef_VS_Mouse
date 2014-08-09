//
//  Timer.h
//  Chef
//
//  Created by fish on 14-7-11.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimerDelegate <NSObject>

- (void) timeup;

@end



@interface Timer : CCNode

- (void) setDelegate:(id)delegate;
- (void) startWithTime:(int)seconds;
- (void) pause;
- (void) resume;
- (void) resetWithTime:(int)seconds;
- (void) reduceTime:(int)seconds;

@end
