//
//  KKSpriteNode+Utilities.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/5/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode+Utilities.h"

@implementation KKSpriteNode (Utilities)
-(CGPoint) positionAtMapX:(int)x andY: (int)y
{
    return CGPointMake((0.5+x)*kTileWidth, (0.5+y)*kTileWidth);
}
-(float) positionXAtMapX:(int)x
{
    return (0.5+x)*kTileWidth;
}
-(float) positionYAtMapY:(int)y
{
    return (0.5+y)*kTileWidth;
}
-(int) mapXatPositionX:(float)x
{
    return  (x/kTileWidth)-0.5;
}
-(int) mapYatPositionY:(float)y
{
    return  (y/kTileWidth)-0.5;
}
-(int) mapXatCurrentPosition
{
    return (self.position.x/kTileWidth)-0.5;
}
-(int) mapYAtCurrentPosition
{
    return (self.position.y/kTileWidth)-0.5;
}
-(float) moveDurationAcrossTiles:(int)tileCount AtSpeed: (float)speed
{
    return abs(tileCount)/speed;
}
@end
