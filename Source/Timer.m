//
//  Timer.m
//  Chef
//
//  Created by fish on 14-7-11.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Timer.h"

@implementation Timer {
    CCNodeColor *_barRef;
    CCNodeColor *_bar;
    CCLabelTTF *_timeLabel;
    
    long millisec;
    long totalTime;
    
    id timerDlg;
    
    int TIME_UPDATE_INTERVAL; //ms, repeat per updateTimeInterval ms
    
    bool isPaused;
    //float bar_ori_pos_width;
    //float bar_ori_pos_height;
}

- (void) didLoadFromCCB
{
    _barRef.visible = TRUE;
    _bar.visible = TRUE;
    isPaused = FALSE;
    
    TIME_UPDATE_INTERVAL = 1000;
    
    NSLog(@"anchorPoint: x=%f, y=%f; position: x=%f, y=%f",_bar.anchorPoint.x, _bar.anchorPoint.y, _bar.position.x, _bar.position.y);
    
}

- (void) setDelegate:(id) delegate
{
    if (delegate != nil && [delegate conformsToProtocol:@protocol(TimerDelegate)]){
        timerDlg = delegate;
    } else {
        NSLog(@"[Timer][setDelegate] Failed to set delegate");
    }
}

- (void) startWithTime:(int)seconds
{
    [self startWithMillisec:((int)seconds)*1000];
}

- (void) startWithMillisec:(long)millisecond
{
    if (millisecond < (signed long)0 ) {
        return;
    }
    
    millisec = millisecond;
    totalTime = millisecond;
    isPaused = FALSE;
    
    [self refreshTimer];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime) userInfo:nil repeats:NO];
}

- (void) resetWithTime:(int)seconds
{
    if (seconds < 0) {
        return;
    }
    millisec = 1000 * seconds;
    totalTime = 1000 * seconds;
    isPaused = FALSE;
    
    [self setBarWithPercentage:1.0];
    [self refreshTimer];
}

- (void) pause
{
    isPaused = TRUE;
}

- (void) resume
{
    isPaused = FALSE;
}

- (void) updateTime
{
    if (isPaused) {
        return;
    }
    if (millisec < 0) {
        return;
    }
    
    millisec = millisec - TIME_UPDATE_INTERVAL;
    if (millisec < 0) {
        millisec = 0;
    }
    
    [self refreshTimer];
    @try {
        if (millisec <= 0) {
            if (timerDlg != nil) {
                [timerDlg timeup];
            }
        } else {
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:NO];
        }
    } @catch (NSException *e) {
        NSLog(@"[Timer][updateTime] Exception: %@", e.description);
    }
}

// display timer
- (void) refreshTimer
{
    if (millisec < 0 || totalTime < 0) {
        return;
    }
    
    int seconds = (int) (millisec/1000);
    NSString * secsForDisplay = [NSString stringWithFormat:@"%d", seconds/60];
    NSString * milsecsForDisplay = seconds%60<10?[NSString stringWithFormat:@"0%d", seconds%60]:[NSString stringWithFormat:@"%d", seconds%60];
    [_timeLabel setString:[NSString stringWithFormat:@"%@:%@", secsForDisplay, milsecsForDisplay]];
    
    int totalSecs = (int) (totalTime/1000);
    float percentage = ((float) seconds)/totalSecs;
    [self setBarWithPercentage:percentage];
}

- (void) setBarWithPercentage:(float)percentage
{
    [_bar setContentSize:CGSizeMake(_barRef.contentSize.width*percentage, _barRef.contentSize.height)];
    /*
    //[visibleBar setContentSize:CGSizeMake(_bar.contentSize.width*percentage, _bar.contentSize.height)];
    NSLog(@"[setBarWithPercentage] totalwidth = %f", _barRef.contentSize.width);
    NSLog(@"[setBarWithPercentage] currentwidth = %f", _barRef.contentSize.width*percentage);
    ///visibleBar.position = _bar.position;
    //visibleBar.anchorPoint = _bar.anchorPoint;
     */
}

//debug by lxp
- (void) reduceTime:(int)seconds
{
    if (seconds <= 0) {
        return;
    }
    
    millisec = millisec - 1000*seconds;
    if (millisec < 0) {
        millisec = 0;
    }
    
    [self refreshTimer];
}

@end
