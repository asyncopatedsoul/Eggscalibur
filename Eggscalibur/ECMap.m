//
//  ECMap.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECMap.h"
#import "ECTile.h"
#import "ECMechUnit.h"

@implementation ECMap

@synthesize units;

-(id) init
{
    self = [super init];
    
    if (self)
    {
        // load map settings
        mapTiles = [[NSMutableArray alloc] init];
        units = [[NSMutableArray alloc] init];
        
        [self render];
    }
    
    return self;
}

-(void) render
{
    NSLog(@"ECMap render");
    // square map;
    CGSize squareMapSize = CGSizeMake(kMapWidth*kTileWidth, kMapWidth*kTileWidth);
    CGPoint squareMapCenterPosition = CGPointMake(kMapWidth*kTileWidth/2, kMapWidth*kTileWidth/2);
    
    mapBackground = [KKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:squareMapSize];
    mapBackground.position = squareMapCenterPosition;
    
    [self addChild:mapBackground];
    
    // create square grid
    for (int y=0; y<kMapWidth; y++) {
        for (int x=0; x<kMapWidth; x++)
        {
            [self addMapTileAtX:x andY:y];
        }
    }
}


-(void) addMapTileAtX:(int)x andY: (int)y
{
    ECTile* mapTile = [[ECTile alloc] initWithWidth:kTileWidth AtX:x andY:y];
    
    [self addChild:mapTile];
    [mapTiles addObject:mapTile];
}

-(void) placeObject:(KKNode*)node AtX:(int)x andY: (int)y
{
    node.position = [self positionAtMapX:x andY:y];
}

-(void) addUnit:(ECMechUnit*)unit ToMapAtX:(int)x andY: (int)y
{
    [units addObject:unit];
    [self addObject:(KKNode*)unit ToMapAtX:x andY:y];
    NSLog(@"map units: %@",units);
}

-(void) addObject:(KKNode*)node ToMapAtX:(int)x andY: (int)y
{
    NSLog(@"adding object at: %i, %i",x,y);
    [self placeObject:node AtX:x andY:y];
    [self addChild:node];
}

-(ECTile*) getTileAtLocation:(CGPoint)point
{
    NSArray* nodesAtPoint = [self nodesAtPoint:point];
    ECTile* tileAtPoint = nil;
    
    for (id node in nodesAtPoint)
    {
        KKNode* childNode = (KKNode*)node;
        
        if ([childNode.name isEqualToString:@"tile"])
            tileAtPoint = (ECTile*)childNode;
    }
    
    return tileAtPoint;
}

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


@end
