//
//  Scoop.m
//  Chef
//
//  Created by fish on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Scoop.h"

@implementation Scoop


- (void)didLoadFromCCB {
    
    // collision
    self.physicsBody.collisionType = @"Scoop";
}

@end
