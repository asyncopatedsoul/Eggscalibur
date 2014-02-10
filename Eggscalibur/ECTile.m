//
//  ECTile.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECTile.h"
#import "ECMechUnit.h"

@implementation ECTile
{
    KKSpriteNode* tileHighlight;
    KKShapeNode* tileOutline;
    KKSpriteNode* mapTile;
    KKSpriteNode* tileMask;
    
    KKSpriteNode* tileStateRoot;
    KKSpriteNode* tileStateIcon;
    
    KKShapeNode* actionDirection;
}

-(id) initWithWidth:(float)width AtX:(int)x andY:(int)y
{
    NSLog(@"ECTile initWithWidthAtXandY");
    self = [super init];
    
    if (self)
    {
        
        
        mappedUnits = [[NSMutableArray alloc] init];
        mapTile = [KKSpriteNode spriteNodeWithImageNamed:@"Tile.png"];
        
        tileHighlight = [KKSpriteNode spriteNodeWithImageNamed:@"BlueTileHighlight.png"];
        tileHighlight.hidden = YES;
        
        tileOutline = [KKShapeNode node];
        CGMutablePathRef tileOutlinePath = CGPathCreateMutable();
        CGPathAddRect(tileOutlinePath, NULL, CGRectMake(-kTileWidth/2, -kTileWidth/2, kTileWidth, kTileWidth));
        tileOutline.path = tileOutlinePath;
        tileOutline.lineWidth = 0.5;
        tileOutline.fillColor = [SKColor clearColor];
        tileOutline.strokeColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        tileOutline.glowWidth = 0.0;
        tileOutline.hidden = YES;
        tileOutline.name = @"tileOutline";
        
        //tileStateRoot = [KKSpriteNode node];
        tileStateRoot = [KKSpriteNode spriteNodeWithImageNamed:@"BlueTile.png"];
        tileStateRoot.hidden = YES;
        tileStateIcon = [KKSpriteNode node];
        
        actionDirection = [KKShapeNode node];
        actionDirection.position = CGPointMake(-10.0, -10.0);
        CGPoint triangle[] = {CGPointMake(0.0, 0.0), CGPointMake(10.0, 20.0), CGPointMake(20.0, 0.0)};
        CGMutablePathRef facingPointer = CGPathCreateMutable();
        CGPathAddLines(facingPointer, NULL, triangle, 3);
        actionDirection.path = facingPointer;
        actionDirection.lineWidth = 1.0;
        actionDirection.fillColor = [SKColor whiteColor];
        actionDirection.strokeColor = [SKColor clearColor];
        actionDirection.glowWidth = 0.0;
        
        
        tileMask = [KKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(kTileWidth, kTileWidth)];
        tileMask.name = @"tileMask";
        tileMask.hidden = YES;
        
        self.name = @"tile";
        self.position = [self positionAtMapX:x andY:y];
        //mapTile.hidden = YES;
        
        ownerId = 0;
        
        [self addChild:mapTile];
        [self addChild:tileHighlight];
        [self addChild:tileOutline];
        
        [self addChild:tileStateRoot];
        
        [self addChild:tileMask];
    }
    return self;
}

-(bool) activateAsRallyPointForUnit:(ECMechUnit*)unit
{
    if ([mappedUnits containsObject:unit])
    {
        NSLog(@"rally point already added");
        return false;
    }
    else
    {
        NSLog(@"adding rally point");

        //tileOutline.hidden = NO;
        tileHighlight.hidden = NO;
        [mappedUnits addObject:unit];
        [unit addRallyPoint:self.position];
        
        return true;
    }
    
}

-(void) deactivateAsRallyPointForUnit:(ECMechUnit*)unit
{
    if ([mappedUnits containsObject:unit])
    {
        [mappedUnits removeObject:unit];
        tileHighlight.hidden = YES;
        NSLog(@"rally point deactivated");
        
        [self setOwner:unit.owner.gameId];
    }
}

-(float) setOwner:(int)newOwnerId
{
    NSLog(@"setting owner for tile: %i",newOwnerId);
    float energyCaptured;
    
    if (ownerId==0){
        energyCaptured = 50.0;
    }
    else if (ownerId == newOwnerId){
        energyCaptured = 10.0;
    }
    else {
        energyCaptured = 75.0;
    }
    
    ownerId = newOwnerId;
    
    if (ownerId == 0)
    {
        //tileStateRoot = [KKSpriteNode spriteNodeWithImageNamed:@"BlueTile.png"];
        tileStateRoot.hidden = NO;
    }
    else if (ownerId == 1)
    {
        //tileRoot.color = [UIColor orangeColor];
    }
    
    return energyCaptured;
}

@end
