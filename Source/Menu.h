//
//  Menu.h
//  Chef
//
//  Created by fish on 14-7-13.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuDelegate

- (void)OnClickRetry;
- (void)OnClickMainMenu;
- (void)OnClickResume;

@end


@interface Menu : CCNode

- (void)setDelegate:(id)delegate;
- (void)OnClickRetry;
- (void)OnClickMainMenu;
- (void)OnClickResume;

@end

