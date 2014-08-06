//
//  Fork.m
//  Chef
//
//  Created by fish on 14-7-9.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Fork.h"

@implementation Fork

- (void)didLoadFromCCB {
    
    // collision
    self.physicsBody.collisionType = @"Fork";
}

@end
