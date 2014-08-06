//
//  WeaponsDisplayer.h
//  Chef
//
//  Created by fish on 14-7-28.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol WeaponsDisplayerDelegate <NSObject>
- (void) OnClickWeaponScoop;
- (void) OnClickWeaponFork;
@end

@interface WeaponsDisplayer : CCNode

- (void) setScoop;
- (void) setFork;
- (void) disableFork;
- (void) setDelegate:(id) delegate;

@end
