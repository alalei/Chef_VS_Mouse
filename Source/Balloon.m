//
//  Balloon.m
//  Chef
//
//  Created by fish on 14-7-25.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Balloon.h"

@implementation Balloon


- (void)didLoadFromCCB {
    
    // collision
    self.physicsBody.collisionType = @"Balloon";
}

@end
