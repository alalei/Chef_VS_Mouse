//
//  WeaponsDisplayer.m
//  Chef
//
//  Created by fish on 14-7-28.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "WeaponsDisplayer.h"

@implementation WeaponsDisplayer {
    CCNode * scoop_valid_mark;
    CCNode * fork_valid_mark;
    CCNode * _scoop;
    CCNode * _fork;
    CCControl * _scoop_btn;
    CCControl * _fork_btn;
    
    id WpDlg;
}

- (id) init {
    self = [super init];
    if (self!= NULL) {
        [self clearValidMark];
    }
    return self;
}

- (void) setDelegate:(id) delegate
{
    if (delegate != nil && [delegate conformsToProtocol:@protocol(WeaponsDisplayerDelegate)]){
        WpDlg = delegate;
        [self setScoop];
    } else {
        NSLog(@"[WeaponsDisplayer][setDelegate] Failed to set delegate");
    }
}

- (void) setScoop {
    [self clearValidMark];
    [scoop_valid_mark setVisible:YES];
    
    if (WpDlg != nil) {
        @try {
            [WpDlg OnClickWeaponScoop];
        }
        @catch (NSException *e) {
            NSLog(@"[WeaponDisplayer][OnClickScoop] Exception: %@", e.description);
        }
    }
}

- (void) setFork {
    [self clearValidMark];
    [fork_valid_mark setVisible:YES];
    
    if (WpDlg != nil) {
        @try {
            [WpDlg OnClickWeaponFork];
        }
        @catch (NSException *e) {
            NSLog(@"[WeaponDisplayer][OnClickFork] Exception: %@", e.description);
        }
    }
}

- (void) disableFork {
    _fork_btn.visible = FALSE;
    _fork.visible = FALSE;
    fork_valid_mark.visible = FALSE;
}

- (void) clearValidMark {
    if (scoop_valid_mark!= NULL) {
        [scoop_valid_mark setVisible:NO];
    }
    if (fork_valid_mark != NULL) {
        [fork_valid_mark setVisible:NO];
    }
}

- (void) OnClickFork
{
    [self setFork];
}

-(void) OnClickScoop
{
    [self setScoop];
}

@end
