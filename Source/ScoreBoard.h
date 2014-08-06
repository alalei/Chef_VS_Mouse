//
//  ScoreBoard.h
//  Chef
//
//  Created by fish on 14-7-17.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol ScoreBoardDelegate <NSObject>

- (void)OnClickRetry;
- (void)OnClickMainMenu;
- (void)OnClickNext;

@end



@interface ScoreBoard : CCNode

- (void) setDelegate:(id) delegate;
- (void) setTitle:(NSString *) title;
- (void) setScore:(int) scores;

@end
