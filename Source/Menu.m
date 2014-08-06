//
//  Menu.m
//  Chef
//
//  Created by fish on 14-7-13.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Menu.h"

@implementation Menu {
    id menuDlg;
}

- (void)didLoadFromCCB {
    // TODO
}

- (void) setDelegate:(id) delegate
{
    if (delegate != nil && [delegate conformsToProtocol:@protocol(MenuDelegate)]){
        menuDlg = delegate;
    } else {
        NSLog(@"[Menu][setDelegate] Failed to set delegate");
    }
}

- (void)OnClickRetry
{
    if (menuDlg != nil) {
        @try {
            [menuDlg OnClickRetry];
        }
        @catch (NSException *e) {
            NSLog(@"[Menu][OnClickRetry] Exception: %@", e.description);
        }
    }
    
}

- (void)OnClickMainMenu
{
    if (menuDlg != nil) {
        @try {
            [menuDlg OnClickMainMenu];
        }
        @catch (NSException *e) {
            NSLog(@"[Menu][OnClickRetry] Exception: %@", e.description);
        }
    }
}

- (void)OnClickResume
{
    if (menuDlg != nil) {
        @try {
            [menuDlg OnClickResume];
        }
        @catch (NSException *e) {
            NSLog(@"[Menu][OnClickRetry] Exception: %@", e.description);
        }
    }
}

@end
