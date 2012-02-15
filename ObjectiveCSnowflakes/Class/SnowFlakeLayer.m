//
//  SnowFlakeLayer.m
//  ObjectiveCSnowflakes
//
//  Created by Chris Whitman on 11-08-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SnowFlakeLayer.h"
#import "Flake.h"

#define FLAKE_INTERVAL 0.5f
#define FLAKE_X_SPEED 115
#define FLAKE_Y_SPEED 50
#define FLAKE_SPIN_SPEED 100
#define FLAKE_FLICK_SPEED 20
#define FLAKE_FLICK_SLOWDOWN 0.95f // The highest the slowest (NOT GO >= 1 or it is infinite)

@implementation SnowFlakeLayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) onEnter{
    
    
    touchedFlake = nil;
    
    
    //
    // Register to touch dispatcher with priority 50
    // Dont have anything with a priority over this
    // Swollows touches = wont affect the scolling of pages
    //
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:50 swallowsTouches:YES];
    
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate=self;
    
    snowFlakes = [[NSMutableArray alloc] init];
    
    for(int i=0;i<0;i++){
        Flake *flake = [Flake spriteWithFile:@"snowflake.png"];
        
        flake.position=ccp(arc4random()%1024,arc4random()%768);
        
        [self addChild:flake];
        
        [snowFlakes addObject:flake];
        
    }
    
    [self schedule:@selector(newFlake) interval:FLAKE_INTERVAL];
    [self schedule:@selector(tick:)];
    
    [super onEnter];
}

//
// Move flakes arround , skip the one that's dragged
//
-(void) tick:(ccTime)dt{
    
    // Create array to put stuff to be deleted in
    // Only alloc it if needed (down in iterate)
    NSMutableArray *toDelete = nil;
    
    // Iterate the flake array
    for(Flake *s in snowFlakes){
        
        if(s.isMoving){
            s.position=ccpAdd(s.position, ccpMult(s.distanceToMove, FLAKE_FLICK_SPEED * dt));
            s.distanceToMove = ccpMult(s.distanceToMove, FLAKE_FLICK_SLOWDOWN);
            s.rotation=s.rotation+FLAKE_SPIN_SPEED*dt;
            if(abs(s.distanceToMove.x) < 1 && abs(s.distanceToMove.y) < 1){
                s.isMoving=NO;
                s.distanceToMove=CGPointZero;
            }
            
        }
        
        // Skip the flake if it's the one dragged
        if(s == touchedFlake) continue;
        
        // Move the flake arround , comparing with accelerometer values
        s.position=ccpAdd(s.position, ccp(accY * FLAKE_X_SPEED * dt,accX * FLAKE_Y_SPEED * dt));
        
        if(s.position.y < 0-s.contentSize.height/2-5){
            if(toDelete==nil) toDelete = [[NSMutableArray alloc] init];
            [toDelete addObject:s];
            [s.parent removeChild:s cleanup:YES];
        }
        
    }
    
    if(toDelete != nil){
        [snowFlakes removeObjectsInArray:toDelete];
        [toDelete release];
    }
    
}

//
// Create a new flake every interval (specified in the define @ top)
//
-(void) newFlake{
    Flake *flake = [Flake spriteWithFile:@"snowflake.png"];
    
    flake.position=ccp(arc4random()%1024,768+flake.contentSize.height/2+5);
    
    [self addChild:flake];
    
    [snowFlakes addObject:flake];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
    //
    // Go thru snow flake to assign one as touchedFlake if touched.
    // Move is in touchMoved
    //
	for(Flake *s in snowFlakes){
        
        if(ccpDistance(touchPoint, s.position)<=s.contentSize.width/2){
            
            // Reset flake isMoving and distanceToMove
            // incase that it's sliding and you retouch it
            s.isMoving=NO;
            s.distanceToMove=CGPointZero;
            
            difTouch = ccpSub(touchPoint, s.position);
            touchedFlake = s;
            
            
            isTouch=YES;
            
            return YES;
            
        }
        
    }
    
	return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    if(isTouch){
        
        //
        // Move the flake, check into consideration finger placement
        // relative to the flake
        //
        touchedFlake.position=ccpSub(touchPoint, difTouch);
        
        lastMovePoint = touchPoint;
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    if(isTouch){
        
        touchedFlake.isMoving=YES;
        touchedFlake.distanceToMove = ccpMult(ccpSub(touchPoint, lastMovePoint),1);
        
        // Adjust the movement if it's too short, make it be bigger.
        if(abs(touchedFlake.distanceToMove.x) < 25 && abs(touchedFlake.distanceToMove.x) < 25){
            
            int whichIsBiggest = abs(touchedFlake.distanceToMove.x);
            if(abs(touchedFlake.distanceToMove.y) > whichIsBiggest) 
                whichIsBiggest = abs(touchedFlake.distanceToMove.y);
            
            touchedFlake.distanceToMove = ccpMult(touchedFlake.distanceToMove, 3);
            
        }
    }
    
    isTouch = NO;
    touchedFlake = nil; // Nillify the pointer, or crash in tick method
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	
    accX = acceleration.x;	
    accY = acceleration.y;

    //
    // Flip the accelerometer values depending on orientation
    //
    if(accX < 0) {
        accY *= -1;
    }

    accX = -1;
}

-(void) onExit{
    
    // Unregister as accelerometer delegate
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	if(accelerometer.delegate==self)accelerometer.delegate=nil;
    
    // Unregister as touch delegate
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super onExit];
}

@end
