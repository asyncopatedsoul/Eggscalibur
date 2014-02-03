//
//  ECMap.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECMap.h"
#import "ECTile.h"

@implementation ECMap

-(void) setup
{
    // load map settings
    
    mapWidth = 10;
    tileWidth = 50.0;
    mapTiles = [[NSMutableArray alloc] init];
}

-(void) render
{
    mapBackground = [KKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(mapWidth*tileWidth, mapWidth*tileWidth)];
    mapBackground.position = CGPointMake(mapWidth*tileWidth/2, mapWidth*tileWidth/2);
    
    [self addChild:mapBackground];
    
    //create square grid
    for (int y=0; y<mapWidth; y++) {
        for (int x=0; x<mapWidth; x++)
        {
            [self addMapTileAtX:x andY:y];
        }
    }
}


-(void) addMapTileAtX:(int)x andY: (int)y
{
    ECTile* mapTile = [ECTile initWithWidth:tileWidth];
    
    [self addChild:mapTile];
    [mapTiles addObject:mapTile];
}

-(void) placeObject:(KKNode*)node AtX:(int)x andY: (int)y
{
    node.position = [self positionAtMapX:x andY:y];
}

-(void) addObject:(KKNode*)node ToMapAtX:(int)x andY: (int)y
{
    [self placeObject:node AtX:x andY:y];
    [mapRoot addChild:node];
}

#pragma mark coordinate utilities

-(CGPoint) positionAtMapX:(int)x andY: (int)y
{
    return CGPointMake((0.5+x)*tileWidth, (0.5+y)*tileWidth);
}
-(float) positionXAtMapX:(int)x
{
    return (0.5+x)*tileWidth;
}
-(float) positionYAtMapY:(int)y
{
    return (0.5+y)*tileWidth;
}
-(int) mapXatPositionX:(float)x
{
    return  (x/tileWidth)-0.5;
}
-(int) mapYatPositionY:(float)y
{
    return  (y/tileWidth)-0.5;
}
-(int) mapXForNode: (KKNode*)node
{
    return (node.position.x/tileWidth)-0.5;
}
-(int) mapYForNode: (KKNode*)node
{
    return (node.position.y/tileWidth)-0.5;
}
-(float) moveDurationAcrossTiles:(int)tileCount AtSpeed: (float)speed
{
    return abs(tileCount)/speed;
}


@end
