//
//  SnowFlakeLayer.h
//  ObjectiveCSnowflakes
//
//  Created by Chris Whitman on 11-08-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class Flake;

@interface SnowFlakeLayer : CCLayer{
    
    NSMutableArray *snowFlakes;
    Flake *touchedFlake;
    BOOL isTouch;
    CGPoint difTouch;
    
    CGPoint lastMovePoint ; // Used to check the drag speed
    
    float accX;
    float accY;
}

@end
