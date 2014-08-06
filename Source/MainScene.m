//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void)play {
    
    @try {
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gamescene"];
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
    
}

- (void) playLevel1
{
    [Gamescene setLevel:level1];
    [self play];
}

- (void) playLevel2
{
    [Gamescene setLevel:level2];
    [self play];
}

- (void) playLevel3
{
    [Gamescene setLevel:level3];
    [self play];
}

@end
