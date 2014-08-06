//
//  Gamescene.h
//  Chef
//
//  Created by fish on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "CCAction.h"
#import <CCActionInterval.h>
#import "CCDirector.h"
#import "CCActionManager.h"

#import "Scoop.h"
#import "Mouse.h"
#import "Chef.h"
#import "Timer.h"
#import "Menu.h"
#import "ScoreBoard.h"
#import "WeaponsDisplayer.h"


typedef enum {
    weapon_scoop =1,
    weapon_fork
} Bullets;

typedef enum {
    level1 =1,
    level2,
    level3
} Levels;

@interface Gamescene : CCNode <CCPhysicsCollisionDelegate, MenuDelegate, ScoreBoardDelegate, TimerDelegate, MouseDelegate, WeaponsDisplayerDelegate>
+ (void) setLevel:(Levels) level;

@end
