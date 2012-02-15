//
//  Flake.h
//  ObjectiveCSnowflakes
//
//  Created by Chris Whitman on 11-08-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Flake : CCSprite{
    BOOL isMoving;
    CGPoint distanceToMove;
}

@property BOOL isMoving;
@property CGPoint distanceToMove;

@end
