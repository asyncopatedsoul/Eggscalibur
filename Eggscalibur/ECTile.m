//
//  ECTile.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECTile.h"

@implementation ECTile

-(id) initWithWidth:(float)width AtX:(int)x andY:(int)y
{
    NSLog(@"ECTile initWithWidthAtXandY");
    self = [super init];
    
    if (self)
    {
        KKSpriteNode* mapTile = [KKSpriteNode spriteNodeWithImageNamed:@"Tile.png"];
        
        KKShapeNode* tileOutline = [KKShapeNode node];
        CGMutablePathRef tileOutlinePath = CGPathCreateMutable();
        CGPathAddRect(tileOutlinePath, NULL, CGRectMake(-kTileWidth/2, -kTileWidth/2, kTileWidth, kTileWidth));
        tileOutline.path = tileOutlinePath;
        tileOutline.lineWidth = 0.5;
        tileOutline.fillColor = [SKColor clearColor];
        tileOutline.strokeColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        tileOutline.glowWidth = 0.0;
        tileOutline.hidden = YES;
        tileOutline.name = @"tileOutline";
        
        KKSpriteNode* tileMask = [KKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(kTileWidth, kTileWidth)];
        tileMask.name = @"tileMask";
        tileMask.hidden = YES;
        
        self.name = @"tile";
        self.position = [self positionAtMapX:x andY:y];
        //mapTile.hidden = YES;
        
        ownerId = 0;
        
        [self addChild:mapTile];
        [self addChild:tileOutline];
        [self addChild:tileMask];
    }
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
