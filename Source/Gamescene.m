//
//  Gamescene.m
//  Chef
//
//  Created by fish on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Gamescene.h"

// level info.
static Levels currentLevel;

@implementation Gamescene {
    
    // Nodes defined in inSpriteBuilder
    CCSprite *_bgNode;
    CCPhysicsNode *_physicsNode;
    Chef *_chef;
    CCNode * _mouse_position_node;
    CCNode * _mouseJointNode;
    Timer *_timer;
    Menu *_menu;
    ScoreBoard *_scoreBoard;
    CCNode *_fly_limit_node;
    WeaponsDisplayer *_weaponsDisplayer;
    CCNode * _level3Node;
    CCNode *_level1_instruction;
    CCNode *_level2_instruction;
    
    // Nodes defined in this file
    Mouse * mouse;
    CCNode *bulletNode;
    // CCActionManager *actionManager;
    
    // moving backgroud in loop
    CCActionSequence * backgroundAction;
    CCActionRepeatForever * repeatRunning;
    CCActionSpeed *bgSpeed;
    
    // scene info.
    int sceneWidth;
    int sceneHeight;
    int backgroundWidth;
    float bgResetPoint;
    float levelBodyStartPoint;
    float levelBodyResetPoint;
    
    // statistic about hits
    unsigned int hitCounter;
    unsigned int score;
    bool isWin;
    
    // weapon info.
    Bullets currentBullet;
}

+ (void) setLevel:(Levels) level
{
    switch (level) {
        case level1:
            currentLevel = level1;
            break;
        case level2:
            currentLevel = level2;
            break;
        case level3:
            currentLevel = level3;
            break;
        default:
            break;
    }
}

- (void)didLoadFromCCB
{
    // debug setting
    _physicsNode.debugDraw = false;
    
    // accept touches
    self.userInteractionEnabled = TRUE;
    
    // collision
    _physicsNode.collisionDelegate = self;
    
    // scene info.
    CGSize screenSize = [CCDirector sharedDirector].viewSize;
    sceneWidth = screenSize.width;
    sceneHeight = screenSize.height;
    backgroundWidth = 1103;
    bgResetPoint = (float)backgroundWidth/3/sceneWidth*(-1);
    levelBodyResetPoint = -1;
    levelBodyStartPoint = 1;
    // levelBodyStartPoint = (float)backgroundWidth/sceneWidth/2;
    
    // moving background
    [self runBackground];
    
    // print runtime information
    NSLog(@"scene width: %d", sceneWidth);
    NSLog(@"scene height: %d", sceneHeight);
    NSLog(@"bgResetPoint: %f", bgResetPoint);
    
    // set menu
    [_menu setDelegate:self];
    _menu.visible = FALSE;
    [_scoreBoard setDelegate:self];
    _scoreBoard.visible = FALSE;
    [_weaponsDisplayer setScoop];
    
    // init statics
    hitCounter = 0;
    score = 0;
    isWin = FALSE;
    [_timer resetWithTime:GAME_TIME_SECOND];
    [_timer startWithTime:GAME_TIME_SECOND];
    [_timer setDelegate:self];
    
    // add mouse
    mouse = (Mouse *)[CCBReader load:@"Mouse"];
    [mouse setScale:0.5f];
    mouse.position = _mouse_position_node.position;
    _mouse_position_node.visible = FALSE;
    [_physicsNode addChild:mouse];
    [mouse setDelegate:self];
    
    // init weapon
    [_weaponsDisplayer setDelegate:self];
    
    // level init
    [_level1_instruction setVisible:FALSE];
    [_level2_instruction setVisible:FALSE];
    
    [self initGameLevel];
}


- (void) initGameLevel
{
    switch (currentLevel) {
        case level1:
            _level3Node.visible = FALSE;
            [_level3Node removeFromParent];
            // set weapon
            [_weaponsDisplayer disableFork];
            [_weaponsDisplayer setScoop];
            [_level1_instruction setVisible:TRUE];
            [self pause];
            NSLog(@"[Gamescene][didLoadFromCCB] level 1");
            break;
        case level2:
            if (mouse != NULL) {
                [mouse flyTo:(sceneHeight * _fly_limit_node.position.y) withTime:2.0f];
            }
            _level3Node.visible = FALSE;
            _level1_instruction.visible = FALSE;
            [_level3Node removeFromParent];
            // set weapon
            [_weaponsDisplayer setScoop];
            
            [mouse setRandomFlyModeWithLeft:sceneWidth/1.5 right:(sceneWidth-100) up:(sceneHeight-60) down:sceneHeight/1.6];
            
            [_level2_instruction setVisible:TRUE];
            [self pause];
            NSLog(@"[Gamescene][didLoadFromCCB] level 2");
            break;
        case level3:
            _level3Node.visible = TRUE;
            _level1_instruction.visible = FALSE;
            // set weapon
            [_weaponsDisplayer setScoop];
            break;
        default:
            NSLog(@"[Gamescene][didLoadFromCCB] currentLevel is not set");
            currentLevel = level1;
            [self initGameLevel];
            break;
    }
}


- (void) level1Play
{
    _level1_instruction.visible = FALSE;
    [_level1_instruction removeFromParentAndCleanup:TRUE];
    [self resume];
}

- (void) level2Play
{
    _level2_instruction.visible = FALSE;
    [_level2_instruction removeFromParentAndCleanup:TRUE];
    [self resume];
}

- (void)launchScoop
{
    [self launchBullet:weapon_scoop];
}

- (void)launchFork
{
    [self launchBullet:weapon_fork];
}

- (void)launchBullet:(Bullets) bullet
{
    CGPoint launchDirection = ccp(1, 0.7);
    
    int distance = _mouseJointNode.position.x - _chef.position.x;
    NSLog(@"distance: %d", distance);
    
    bulletNode.physicsBody.allowsRotation = true;
    
    switch (bullet)
    {
        case weapon_scoop:
            bulletNode = [CCBReader load:@"Scoop"];
            launchDirection = ccp(1, 0.7);
            break;
        case weapon_fork:
            bulletNode = [CCBReader load:@"Fork"];
            
            float max_ref = MAX(_mouseJointNode.position.x - _chef.position.x, _mouseJointNode.position.y - _chef.position.y);
            
            launchDirection = ccp((_mouseJointNode.position.x - _chef.position.x)/max_ref, (_mouseJointNode.position.y - _chef.position.y)/max_ref);
            // rotate the bullets
            float angle = - atan(launchDirection.y/launchDirection.x);
            [bulletNode runAction:[CCActionRotateBy actionWithDuration:0 angle:(angle/3.14)*180]];
            // NSLog(@"bullet rotate angle: %f",angle);
            // bulletNode.physicsBody.allowsRotation = FALSE;
            break;
        default:break;
    }
    
    if (bulletNode == nil) {
        return;
    }

    bulletNode.position = ccpAdd(_chef.position, ccp(70, 60));
    [_physicsNode addChild:bulletNode];

    CGPoint force;
    @try {
        switch (bullet)
        {
            case weapon_scoop:
                // manually create and apply a force to launch the bullt
                force = ccpMult(launchDirection, distance*5);
                [bulletNode.physicsBody applyForce:force];
                // [bulletNode runAction:[CCActionRemove action]];
                break;
            case weapon_fork:
                force = ccpMult(launchDirection, distance*2);
                [bulletNode.physicsBody applyForce:force];
                break;
            default:break;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception.description);
    }

    
}

/*
 * -----------  Touch Events  -----------
 *
 * - called on every touch in this scene
 * --------------------------------------
 */

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // NSLog(@"Touch begin");
    
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    
    // move the mouseJointNode to the touch position
    _mouseJointNode.position = touchLocation;
    
    // start lauching bullets when a touch inside of the scene
    if (CGRectContainsPoint([_physicsNode boundingBox], touchLocation)){
        
        @try {
            CGRect chefLocation = [_chef boundingBox];
            CGFloat origin_x = chefLocation.origin.x - chefLocation.size.width*0.2;
            CGFloat origin_y = chefLocation.origin.y - chefLocation.size.height*0.2;
            origin_x = origin_x<0?0:origin_x;
            origin_x = origin_x>sceneWidth?sceneWidth:origin_x;
            origin_y = origin_y<0?0:origin_y;
            origin_y = origin_y>sceneHeight?sceneHeight:origin_y;
            CGRect chefTouchLocation = CGRectMake(origin_x, origin_y, chefLocation.size.width*1.4, chefLocation.size.height*1.4);
            
            // Chef jump if click chef
            if (CGRectContainsPoint(chefTouchLocation, touchLocation)) {
                [_chef jumpTo:(sceneHeight/2 * _fly_limit_node.position.y) withTime:2.0f];
            }
            // Chef launch bullet if click other place
            else {
                [self launchBullet:currentBullet];
                // [self launchScoop];
                // [self launchFork];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"[Gamescene][touchBegan] Exception: %@", exception.description);
        }
    }
    
}


- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"Touch moved");
}


-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"Touch ended");
    
}


-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"Touch cancelled");
}



/*
 * -----------  Collision Events  -----------
 *
 * - called when weapons touch targets
 * --------------------------------------
 */
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Scoop:(Scoop *)scoop wildcard:(CCNode *)target
{
    // NSLog(@"target class scoop %@", [target class]);
    
    if ([target isKindOfClass:[Weapon class]]) {
        return;
    }
    
    if ([target isKindOfClass:[Mouse class]]) {
        
        float energy = [pair totalKineticEnergy];
        [(Mouse *)target hittedBy:(Scoop *)scoop withEnergy:energy];
        
        // update hit statistics
        hitCounter++;
        
        if (energy < 1000) {
            score += energy/3;
        } else if (energy < 2000){
            score += energy/2.5;
        } else if (energy < 3000) {
            score += energy/2;
        } else if (energy >= 3000) {
            score += energy/1.6;
        }
        
        // mouse reaction dependent on game levels
        switch (currentLevel) {
            case level1:
                if (mouse.blood < MOUSE_BLOOD/2) {
                    [(Mouse *)target flyTo:(sceneHeight * _fly_limit_node.position.y) withTime:2.0f];
                }
                break;
            case level2:
                [(Mouse *)target flyTo:(sceneHeight * _fly_limit_node.position.y) withTime:2.0f];
                break;
            case level3:
                if (mouse.blood < MOUSE_BLOOD/2) {
                    [(Mouse *)target flyTo:(sceneHeight * _fly_limit_node.position.y * 1.1) withTime:2.0f];
                }
                break;
            default:
                break;
        }
        

    }
    
    [scoop removeFromParent];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Fork:(Fork *)fork wildcard:(CCNode *)target
{
    // NSLog(@"target class Fork %@", [target class]);
    
    if ([target isKindOfClass:[Weapon class]]) {
        return;
    }
    
    if ([target isKindOfClass:[Mouse class]]) {
        NSLog(@"Mouse hitted by fork");
        float energy = [pair totalKineticEnergy];
        [(Mouse *)target hittedBy:(Fork *)fork withEnergy:energy];
        
        // update hit statistics
        hitCounter++;
        
        // debug
        [(Mouse *)target flyTo:(sceneHeight * _fly_limit_node.position.y) withTime:2.0f];

    }
    
    [fork removeFromParent];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Balloon:(Balloon *)balloon Fork:(Fork *)fork
{
    // NSLog(@"balloon hitted by fork");
    // NSLog(@"target class Balloon %@", [fork class]);
    float energy = [pair totalKineticEnergy];
    NSLog(@"Balloon energy: %f",energy);
    if (energy > 1000) {
        [mouse balloonShooted];
    }
}

/*
 * -----------  Game Components  -----------
 *
 * - called when click menu controllers
 * --------------------------------------
 */

- (void) OnClickWeaponScoop
{
    currentBullet = weapon_scoop;
}

- (void) OnClickWeaponFork
{
    currentBullet = weapon_fork;
}

- (void) OnClickMenu
{
    NSLog(@"clicked Menu");
    @try {
        [self pause];
        _menu.visible = TRUE;
    } @catch (NSException * e) {
        NSLog(@"[Gamescene][OnClickMenu] Exception: %@", e.description);
    }
    
}

- (void)OnClickRetry
{
    NSLog(@"clicked Retry");
    @try {
        // [[CCDirector sharedDirector]replaceScene:[CCBReader loadAsScene:@"Gamescene"]];
        [self retry];
    } @catch (NSException * e) {
        NSLog(@"[Gamescene][OnClickMenu] Exception: %@", e.description);
    }
}

- (void)OnClickMainMenu
{
    NSLog(@"clicked MainMenu");
    @try {
        _menu.visible = FALSE;
        [self resume];
        [[CCDirector sharedDirector]replaceScene:[CCBReader loadAsScene:@"MainScene"]];
    } @catch (NSException * e) {
        NSLog(@"[Gamescene][OnClickMenu] Exception: %@", e.description);
    }
}

- (void)OnClickResume
{
    NSLog(@"clicked Resume");
    @try {
        _menu.visible = FALSE;
        [self resume];
    } @catch (NSException * e) {
        NSLog(@"[Gamescene][OnClickResume] Exception: %@", e.description);
    }
}

- (void)OnClickNext
{
    switch (currentLevel) {
        case level1:
            currentLevel = level2;
            break;
        case level2:
            currentLevel = level3;
            break;
        case level3:
            currentLevel = level1;
            break;
        default:
            break;
    }
    // [self resume];
    [self retry];
    
}

- (void)afterDie
{
    // TODO
    NSLog(@"[Gamescene] mouse die");
    isWin = TRUE;
    [self finishGame];
}

- (void) balloonShooted
{
    if (mouse != nil) {
        [mouse fallToHeight:_mouse_position_node.position.y WithTime:2.0f];
    }
}

- (void) timeup
{
    NSLog(@"----- Time up!!! -----");
    [self finishGame];
}

- (void) retry
{
    [self resume];
    [[CCDirector sharedDirector]replaceScene:[CCBReader loadAsScene:@"Gamescene"] withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

- (void) pause
{
    [[CCDirector sharedDirector] pause];
    [_timer pause];
}

- (void) resume
{
    [[CCDirector sharedDirector] resume];
    [_timer resume];
}

- (void) runBackground
{
    CCActionMoveTo *bgMove = [CCActionMoveTo actionWithDuration:5.0f position:ccp(bgResetPoint,0)];
    CCActionMoveTo *bgReset = [CCActionMoveTo actionWithDuration:0 position:ccp(0,0)];
    backgroundAction = [CCActionSequence actionOne:[bgMove copy] two:[bgReset copy]];
    repeatRunning = [CCActionRepeatForever actionWithAction:backgroundAction];
    bgSpeed =[CCActionSpeed actionWithAction:repeatRunning speed:1.0f];
    [_bgNode runAction:bgSpeed];
    
    if (currentLevel==level3 && _level3Node!= NULL) {
        CCActionMoveTo *bgMove2 = [CCActionMoveTo actionWithDuration:6.0f position:ccp(levelBodyResetPoint,0)];
        CCActionMoveTo *bgReset2 = [CCActionMoveTo actionWithDuration:0 position:ccp(levelBodyStartPoint,0)];
        CCAction *backgroundAction2 = [CCActionSequence actionOne:[bgMove2 copy] two:[bgReset2 copy]];
        CCAction *repeatRunning2 = [CCActionRepeatForever actionWithAction:backgroundAction2];
        CCAction *bgSpeed2 =[CCActionSpeed actionWithAction:repeatRunning2 speed:1.0f];
        // [_level3Node runAction:[CCActionFollow actionWithTarget:_bgNode]];
        [_level3Node runAction:bgSpeed2];
    }
}

/*
- (void) resetBackground
{
    CCActionMoveTo *bgReset = [CCActionMoveTo actionWithDuration:0.5 position:ccp(0,0)];
    [_bgNode runAction:bgReset];
}
*/


- (void) finishGame
{
    
    score += hitCounter*200;
    [_scoreBoard setScore:score];
    if (isWin) {
        [_scoreBoard setTitle:@"You Win!"];
        // win the game
        NSLog(@"----- You Win!!! -----");
    } else {
        [_scoreBoard setTitle:@"Try again!"];
        // time up or other conditions
        NSLog(@"----- Sorry, time up -----");
        [self pause];
    }
    
    _scoreBoard.visible = TRUE;
}

@end


