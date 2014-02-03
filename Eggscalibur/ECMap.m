//
//  ECMap.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECMap.h"

@implementation ECMap

-(void) render
{
    mapWidth = 10;
    
    mapRoot = [KKNode node];
    KKSpriteNode* mapBackground = [KKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(mapWidth*tileWidth, mapWidth*tileWidth)];
    mapBackground.position = CGPointMake(mapWidth*tileWidth/2, mapWidth*tileWidth/2);
    
    [mapRoot addChild:mapBackground];
    [self addChild:mapRoot];
    
    mapTiles = [[NSMutableArray alloc] init];
    
    //create 10x10 grid
    for (int y=0; y<10; y++) {
        for (int x=0; x<10; x++)
        {
            [self addMapTileAtX:x andY:y];
        }
    }
}


-(void) addMapTileAtX:(int)x andY: (int)y
{
    
    KKSpriteNode* mapTile = [KKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(tileWidth, tileWidth)];
    
    KKShapeNode* tileOutline = [KKShapeNode node];
    CGMutablePathRef tileOutlinePath = CGPathCreateMutable();
    CGPathAddRect(tileOutlinePath, NULL, CGRectMake(-tileWidth/2, -tileWidth/2, tileWidth, tileWidth));
    tileOutline.path = tileOutlinePath;
    tileOutline.lineWidth = 1.0;
    tileOutline.fillColor = [SKColor clearColor];
    tileOutline.strokeColor = [SKColor whiteColor];
    tileOutline.glowWidth = 0.0;
    tileOutline.hidden = YES;
    tileOutline.name = @"tileOutline";
    
    KKSpriteNode* tileMask = [KKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(tileWidth, tileWidth)];
    tileMask.name = @"tileMask";
    tileMask.hidden = YES;
    
    mapTile.name = @"tile";
    mapTile.position = [self positionAtMapX:x andY:y];
    //mapTile.hidden = YES;
    mapTile.userData = [[NSMutableDictionary alloc] init];
    [mapTile.userData setValue:[NSNumber numberWithInt:0] forKey:@"ownerId"];
    
    [mapTile addChild:tileOutline];
    [mapTile addChild:tileMask];
    
    [mapRoot addChild:mapTile];
    
    [mapTiles addObject:tileOutline];
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
