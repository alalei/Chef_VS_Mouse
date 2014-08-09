//
//  Mouse.h
//  Chef
//
//  Created by fish on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "GameParams.h"
#import "Weapon.h"
#import "Scoop.h"
#import "Fork.h"
#import "Balloon.h"

#import "CCActionInstant.h"

@protocol MouseDelegate <NSObject>

- (void) afterDie;
- (void) balloonShooted;

@end


@interface Mouse : CCNode

@property (nonatomic, assign) int blood;

- (void) setDelegate:(id)delegate;
- (void) hittedBy:(Weapon *) weapon withEnergy:(float) energy;
- (void) balloonShooted;
- (void) die;

- (void) flyTo:(int)height withTime:(float)seconds;
- (void) fallToHeight:(int)height WithTime:(float)seconds;
- (void) setRandomFlyModeWithLeft:(int)left right:(int)right up:(int)up down:(int)down;
- (void) setRandomWalkModeWithLeft:(int)left right:(int)right;

// TODO
// - (void) giveUpThings;
// - (void) stopForSeconds:(float) seconds;

@end
