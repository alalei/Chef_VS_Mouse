//
//  ScoreBoard.m
//  Chef
//
//  Created by fish on 14-7-17.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "ScoreBoard.h"

@implementation ScoreBoard {
    id SBDlg;
    CCLabelTTF *_title;
    CCLabelTTF *_score;
}


- (void)didLoadFromCCB {
    // TODO
}

- (void) setDelegate:(id) delegate
{
    if (delegate != nil && [delegate conformsToProtocol:@protocol(ScoreBoardDelegate)]){
        SBDlg = delegate;
    } else {
        NSLog(@"[Scoreboard][setDelegate] Failed to set delegate");
    }
}

- (void)OnClickRetry
{
    if (SBDlg != nil) {
        @try {
            [SBDlg OnClickRetry];
        }
        @catch (NSException *e) {
            NSLog(@"[Scoreboard][OnClickRetry] Exception: %@", e.description);
        }
    }
}

- (void)OnClickMainMenu
{
    if (SBDlg != nil) {
        @try {
            [SBDlg OnClickMainMenu];
        }
        @catch (NSException *e) {
            NSLog(@"[Scoreboard][OnClickMainMenu] Exception: %@", e.description);
        }
    }
}

- (void)OnClickNext
{
    if (SBDlg != nil) {
        @try {
            [SBDlg OnClickNext];
        }
        @catch (NSException *e) {
            NSLog(@"[Scoreboard][OnClickNext] Exception: %@", e.description);
        }
    }
}

- (void) setTitle:(NSString *) title
{
    [_title setString:title];
}

- (void) setScore:(int) scores
{
    [_score setString:[NSString stringWithFormat:@"Scores: %d", scores]];
}

@end
