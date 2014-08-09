//
//  Mouse.m
//  Chef
//
//  Created by fish on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Mouse.h"

@implementation Mouse {
    
    CCLabelTTF * _bloodLabel;
    CCNode * _balloon_node;
    CCNode * _mouse_body;
    
    CCNodeColor *_bar;
    CCNodeColor *_barRef;
    Balloon * balloon;
    Boolean isBlink;
    id MouseDlg;
    bool isLive;
    bool isFlying;
    bool isStable;
    NSObject *stableLock;
    int groundHeight;
    
    // random fly mode
    Boolean isRandomFly;
    Boolean isRandomWalk;
    int rLeft;
    int rRight;
    int rUp;
    int rDown;
    int randomFlyThreshold;
    float randomFlyFade;
    int randomWalkThreshold;
}

- (id)init
{
    self = [super init];
    if (self!= NULL) {
        [_balloon_node setVisible:FALSE];
        [_mouse_body setVisible:TRUE];
        
        self.blood = MOUSE_BLOOD;
        isBlink = FALSE;
        isLive = TRUE;
        isFlying = FALSE;
        isStable = TRUE;
        isRandomFly = FALSE;
        randomFlyThreshold = 0;
        randomFlyFade = 1;
        /*
        _balloon_node.visible = NO;
        _mouse_body.visible = YES;
         */
    }
    return self;
}

- (void)didLoadFromCCB {
    [_balloon_node setVisible:FALSE];
    [_mouse_body setVisible:TRUE];
    NSLog(@"[Mouse][didLoadFromCCB]");
    
    self.blood = MOUSE_BLOOD;
    isBlink = FALSE;
    isLive = TRUE;
    isFlying = FALSE;
    isStable = TRUE;
    isRandomFly = FALSE;
    randomFlyThreshold = 0;
    randomFlyFade = 1;
    isRandomWalk = FALSE;
    randomWalkThreshold = 0;
    
    // Locker
    stableLock = [[NSObject alloc] init];
    
    // blood bar
    [self setBloodVisibility:NO];
}

- (void) setDelegate:(id) delegate
{
    if (delegate != nil && [delegate conformsToProtocol:@protocol(MouseDelegate)]){
        MouseDlg = delegate;
        [_balloon_node setVisible:FALSE];
    } else {
        NSLog(@"[Mouse][setDelegate] Failed to set delegate");
    }
}

- (void) setRandomFlyModeWithLeft:(int)left right:(int)right up:(int)up down:(int)down
{
    rLeft = left;
    rRight = right;
    rUp = up;
    rDown = down;
    randomFlyThreshold = 0;
    randomFlyFade = 1;
    isRandomFly = TRUE;
    NSLog(@"[Mouse][setRandomFlyModeWithLeft:%d, right:%d, up:%d, down:%d]", left, right, up, down);
}

- (void) setRandomWalkModeWithLeft:(int)left right:(int)right
{
    rLeft = left;
    rRight = right;
    isRandomWalk = TRUE;
}

- (void) randomFly
{
    if ((!isFlying) || (!isStable)) {
        return;
    }
    
    if (self.blood < MOUSE_BLOOD /2 && randomFlyFade > 0.1) {
        randomFlyFade -= 0.2;
    } else if (randomFlyFade == 0) {
        [self setVisible:FALSE];
    }
    
    int width = (rRight - rLeft);
    int height = (rUp - rDown);
    int p_x = rLeft + rand()%width;
    int p_y = rDown + rand()%height;
    
    CCAction * move = [CCActionMoveTo actionWithDuration:0.2f position:ccp(p_x, p_y)];
    // CCAction * fade = [CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.2f] two:[CCActionFadeIn actionWithDuration:0.2f]];
    CCAction * fade = [CCActionFadeTo actionWithDuration:2.0f opacity:randomFlyFade];
    NSLog(@"[Mouse][randomFly] move to: [%d, %d], fade: %f", p_x, p_y, randomFlyFade);
    // [self runAction:[CCActionSpawn actionOne:move two:fade]];

    [self runAction:[CCActionSequence actionOne:move two:fade]];
}

- (void) randomWalk
{
    if ((isFlying) || (!isStable)) {
        return;
    }
    
    int width = (rRight - rLeft);
    int p_x = rLeft + rand()%width;
    int p_y = self.position.y;
    
    CCAction * move = [CCActionMoveTo actionWithDuration:0.2f position:ccp(p_x, p_y)];
    [self runAction:move];
}

- (void) hittedBy:(Weapon *) weapon withEnergy:(float) energy
{
    // NSLog(@"mouse is hitted with energy: %f", energy);

    if (!isLive) {
        return;
    }
    
    int hitFactor = HIT_FACTOR_SCOOP;
    
    if ([(CCNode *)weapon isKindOfClass:[Scoop class]]) {
        hitFactor = HIT_FACTOR_SCOOP;
        // NSLog(@"[Mouse hittedBy] hit by Scoop, hit factor: %d", hitFactor);
    } else if ([(CCNode *)weapon isKindOfClass:[Fork class]]) {
        hitFactor = HIT_FACTOR_FORK;
        // NSLog(@"[Mouse hittedBy] hit by Fork, hit factor: %d", hitFactor);
    }
    
    int bloodLoss = (-1) * hitFactor * energy + rand()%10;
    if (bloodLoss < -3500 || bloodLoss > 3500) {
        bloodLoss = -3500;
    }
    self.blood += bloodLoss;
    
    // set blood bar
    if (_bar.visible != YES) {
        [self setBloodVisibility:YES];
    }
    [self refreshBloodBar:self.blood withTotal:MOUSE_BLOOD];
    
    if (isRandomFly) {
        randomFlyThreshold += (-bloodLoss);
        if (randomFlyThreshold > 5000 && isStable) {
            NSLog(@"[Mouse][randomFly] randomFlyThreshold: %d", randomFlyThreshold);
            randomFlyThreshold = 0;
            [self randomFly];
        } else {
            
        }
    }
    if (isRandomWalk) {
        if (isFlying || (!isStable)) {
            randomWalkThreshold = 0;
        } else {
            randomWalkThreshold += (-bloodLoss);
            if (randomWalkThreshold > 5000) {
                [self randomWalk];
            }
        }
    }
    
    // display lost blood
    CCLabelTTF *bloodlabel = [[CCLabelTTF alloc] init];
    bloodlabel.position = _bloodLabel.position;
    [bloodlabel setFontSize:_bloodLabel.fontSize];
    [bloodlabel setFontName:_bloodLabel.fontName];
    bloodlabel.color = _bloodLabel.color;
    [bloodlabel setString:[NSString stringWithFormat:@"%d",bloodLoss]];
    [self addChild:bloodlabel];
    
    CCActionSequence * seq1 = [CCActionSequence actions:
                               [CCActionDelay actionWithDuration:0.3f],
                               [CCActionFadeOut actionWithDuration:0.3f],
                               nil]; //[CCActionFadeIn actionWithDuration:0.1f],
    CCActionSequence * seq2 = [CCActionSequence actions:
                               [CCActionMoveBy actionWithDuration:0.4f position:ccp(-4,64)],
                               [CCActionMoveBy actionWithDuration:0.2f position:ccp(-1,16)],
                                nil];
    CCActionSpawn * spawn1 = [CCActionSpawn actions:seq1, seq2, nil];
    // CCAction * fade2 = [CCActionFadeOut actionWithDuration:0.2f];
    /*
    CCAction * action3 = [CCActionCallBlock actionWithBlock:^{
        [bloodlabel setVisible:false];
        // bloodlabel.position = _bloodLabel.position;
    }];*/
    [bloodlabel runAction:spawn1];
    
    
    // NSLog(@"Left blood: %d", self.blood);
    if (self.blood < 0) {
        NSLog(@"mouse is eliminated");
        isLive = FALSE;
        [self die];
    } else if (self.blood < MOUSE_BLOOD/2) {
        NSLog(@"mouse lost half blood");
        // [self blinkDuringTime:0.5f withOpacity:0.5f andOpacity:1.0f];
    }
    
}

/*
- (void) stopForSeconds:(float) seconds{
    
}
*/

// if mouse become weak, then blink
- (void) blinkDuringTime:(float)time withOpacity:(float)opacity1 andOpacity:(float)opacity2
{
    if (isBlink) {
        return;
    }
    
    // CCAction * blink = [CCActionBlink actionWithDuration:0.5f blinks: 2];
    CCAction * action1 = [CCActionFadeTo actionWithDuration:time opacity:opacity1];
    CCAction * action2 = [CCActionFadeTo actionWithDuration:time opacity:opacity2];
    [self runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:action1, action2, nil]]];
    isBlink = TRUE;
}

- (void) die
{
    NSLog(@"[Mouse][die]");
    [self setVisible:NO];
    [_balloon_node setVisible:NO];
    
    if (MouseDlg != nil) {
        @try {
            [MouseDlg afterDie];
        }
        @catch (NSException *e) {
            NSLog(@"[Mouse][die] %@", e.description);
        }
    }
}

- (void) flyTo:(int)height withTime:(float)seconds
{
    @synchronized(stableLock) {
        NSLog(@"[Mouse][flyTo] locker: start");
        if (isFlying || (!isStable)) {
            NSLog(@"[Mouse][flyTo] locker: end");
            return;
        }
        
        int flyHeight = height;
        if (isRandomFly && (height > rUp)) {
            flyHeight = rUp;
        }
        
        NSLog(@"[Mouse][flyTo] height: %d, time: %f", flyHeight, seconds);
        isFlying = TRUE;
        isStable = FALSE;
        CCAction *flyAct = [CCActionMoveTo actionWithDuration:seconds position:ccp(self.position.x, flyHeight)];
        // CCAction *delay = [CCActionDelay actionWithDuration:0.5f];
        
        CCAction *reset = [CCActionCallBlock actionWithBlock:^{
            isStable = TRUE;
        }];
        CCAction *rotation = [CCActionRotateTo actionWithDuration:1.5f angle:45];
        // CCAction *final = [CCActionSpawn actionOne:[CCActionSequence actions:flyAct, nil] two:rotation];
        
        // Add balloon
        // [_balloon_node setVisible:TRUE];
        balloon = (Balloon *)[CCBReader load:@"Balloon"];
        balloon.position = _balloon_node.position;
        [self addChild:balloon];
        
        [self runAction:[CCActionSequence actionOne:flyAct two:reset]];
        [_mouse_body runAction:rotation];
        
        /*
         CCAction *balloonRotate = [CCActionRotateBy actionWithDuration:1.5f angle:-45];
         CCAction *balloonMove = [CCActionMoveBy actionWithDuration:1.5f position:ccp( (int)(-(float)self.position.y/1.5), 0)];
         CCActionSpawn *balloonReverse = [CCActionSpawn actionOne:balloonRotate two:balloonMove];
         [balloon runAction:balloonReverse];
         */
        NSLog(@"[Mouse][flyTo] locker: end");
    }
}

- (void) balloonShooted
{
    [MouseDlg balloonShooted];
    [balloon removeFromParent];
}

- (void) fallToHeight:(int)height WithTime:(float)seconds
{
    @synchronized(stableLock) {
        NSLog(@"[Mouse][fallToHeight] locker: start");
        /*
         CCAction *fallAct = [CCActionMoveTo actionWithDuration:seconds position:ccp(self.position.x, height)];
         CCAction *delay = [CCActionDelay actionWithDuration:0.5f];
         CCAction *rotation = [CCActionRotateBy actionWithDuration:1.5f angle:45];
         CCAction *final = [CCActionSpawn actionOne:[CCActionSequence actions:flyAct, nil] two:rotation];
         */
        
        isStable = FALSE;
     }
    
    [self stopAllActions];
    [_mouse_body stopAllActions];
    NSLog(@"[Mouse][fallToHeight] stop previous action");
    
    CCAction *rotation = [CCActionRotateTo actionWithDuration:0.5f angle:0];
    CCAction *fallAct = [CCActionMoveTo actionWithDuration:seconds position:ccp(self.position.x, height)];
    CCAction *reset = [CCActionCallBlock actionWithBlock:^{
        isStable = TRUE;
        isFlying = FALSE;
    }];
    
    // CCAction *final = [CCActionSpawn actionOne:[CCActionSequence actions:fallAct, reset, nil] two:rotation];
    
    [self runAction:[CCActionSequence actions:fallAct, reset, nil]];
    [_mouse_body runAction:rotation];
    NSLog(@"[Mouse][fallToHeight] start fall actions");
    NSLog(@"[Mouse][fallToHeight] locker: end");

}

- (void) setBloodVisibility:(BOOL)visible
{
    [_barRef setVisible:visible];
    [_bar setVisible:visible];
}

// display timer
- (void) refreshBloodBar:(int)currentBlood withTotal:(int)totalBlood
{
    float percentage = ((float)currentBlood)/totalBlood;
    [_bar setContentSize:CGSizeMake(_barRef.contentSize.width, _barRef.contentSize.height*percentage)];
}

/*
- (void) giveUpThings
{
    
}
*/
@end
