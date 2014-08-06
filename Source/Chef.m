//
//  Chef.m
//  Chef
//
//  Created by fish on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Chef.h"

@implementation Chef {
    bool isJumping;
}

- (void)didLoadFromCCB {
    NSLog(@"[Chef][didLoadFromCCB] isJumping = FALSE");
    isJumping = FALSE;
}

/*
- (id)init
{
    self = [super init];
    if (self!= NULL) {
        isJumping = FALSE;
    }
    NSLog(@"[Chef] init");
    return self;
}
*/

- (void) jumpTo:(int)height withTime:(float)seconds
{
    if (isJumping) {
        return;
    }
    isJumping = TRUE;
    NSLog(@"[Chef][jumpTo] begin");
    
    CCAction *jumpAct = [CCActionJumpTo actionWithDuration:seconds position:self.position height:height jumps:1];
    CCAction *delay = [CCActionDelay actionWithDuration:0.5f];
    CCAction *reset = [CCActionCallBlock actionWithBlock:^{
        isJumping = FALSE;
    }];
    [self runAction:[CCActionSequence actions:jumpAct, reset, nil]];
}

@end
