//
//  Utilities.c
//  Eggscalibur
//
//  Created by Michael Garrido on 2/5/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#include <stdio.h>

#pragma mark coordinate utilities

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
-(int) mapXForNode: (KKNode*)node
{
    return (node.position.x/kTileWidth)-0.5;
}
-(int) mapYForNode: (KKNode*)node
{
    return (node.position.y/kTileWidth)-0.5;
}
-(float) moveDurationAcrossTiles:(int)tileCount AtSpeed: (float)speed
{
    return abs(tileCount)/speed;
}