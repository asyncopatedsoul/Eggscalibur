//
//  ECTile.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECTile.h"

@implementation ECTile

-(id) initWithWidth:(float)width
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
    
    return self;
}

-(float) setOwner:(int)ownerId ForTile:(KKSpriteNode*)tileRoot
{
    int currentTileOwner = [[tileRoot.userData valueForKey:@"ownerId"] integerValue];
    float energyCaptured;
    
    if (currentTileOwner==0){
        energyCaptured = 50.0;
    }
    else if (ownerId == currentTileOwner){
        energyCaptured = 10.0;
    }
    else {
        energyCaptured = 75.0;
    }
    
    [tileRoot.userData setValue:[NSNumber numberWithInt:ownerId] forKey:@"ownerId"];
    
    if (ownerId == 1)
    {
        tileRoot.color = [UIColor greenColor];
    }
    else if (ownerId == 2)
    {
        tileRoot.color = [UIColor orangeColor];
    }
    
    return energyCaptured;
}

@end
