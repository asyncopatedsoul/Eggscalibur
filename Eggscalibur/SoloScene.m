//
//  SoloScene.m
//  Eggscalibur
//
//  Created by Michael Garrido on 1/26/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "SoloScene.h"

@implementation SoloScene
{
    float tileWidth;
    KKNode* mapRoot;
    KKNode* selectedUnit;
    KKNode* touchIndicatorRoot;
    NSMutableArray* mapTiles;
    
    bool canSetRallyPoints;
    
    //unit properties
    NSMutableArray* rallyPointQueue;
    float movementSpeed;
    float energyLevel;
    float energyMax;
    float indicatorBarWidth;
    KKSpriteNode* energyIndicator;
}

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		/* Setup your scene here */
		self.backgroundColor = [SKColor colorWithRed:0.4 green:0.0 blue:0.4 alpha:1.0];
        tileWidth = 50.0;
        canSetRallyPoints = NO;
        
        [self renderMap];
		
	}
	return self;
}

-(void) renderMap
{
    mapRoot = [KKNode node];
    [self addChild:mapRoot];
    
    mapTiles = [[NSMutableArray alloc] init];
    
    //create 10x10 grid
    for (int y=0; y<10; y++) {
        for (int x=0; x<10; x++)
        {
             [self addMapTileAtX:x andY:y];
        }
    }
    
    touchIndicatorRoot = [KKNode node];
    KKSpriteNode* touchIndicator = [KKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(tileWidth, tileWidth)];
    [touchIndicatorRoot addChild:touchIndicator];
    touchIndicatorRoot.hidden = YES;
    [mapRoot addChild:touchIndicatorRoot];
    
    [self setupUnits];
}

-(void) setupUnits
{
    float unitWidth = 40.0;
    
    indicatorBarWidth = 30.0;
    
    //player's squad
    KKNode* mechUnit = [KKNode node];
    
    KKSpriteNode* mechUnitBody = [KKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(unitWidth, unitWidth)];
    mechUnitBody.name = @"unit";
    
    energyIndicator = [KKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(indicatorBarWidth, 5.0)];
    energyIndicator.position = CGPointMake(0.0,40.0);
    
    [mechUnit addChild:energyIndicator];
    [mechUnit addChild:mechUnitBody];
    
    
    selectedUnit = mechUnit;
    energyMax = 1000.0;
    energyLevel = 1000.0;
    movementSpeed = 2.0;
    rallyPointQueue = [[NSMutableArray alloc] init];
    
                                  
    [self addObject:mechUnit ToMapAtX:1 andY:5];
    
}
-(void) updateEnergyIndicator
{
    SKAction *resizeIndicator = [SKAction resizeToWidth:indicatorBarWidth*(energyLevel/energyMax) duration:movementSpeed/2];
    [energyIndicator runAction:resizeIndicator];
}

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

-(SKAction*) moveUnitToX:(int)x andY: (int)y
{
    //TODO calculate duration from unit's movement speed
    int tileCountX = x-[self mapXForNode:selectedUnit];
    int tileCountY = y-[self mapYForNode:selectedUnit];
    NSLog(@"moving by tiles: %i, %i", tileCountX, tileCountY);
    
    //horizontal and vertical movement is separated
    SKAction *unitMoveHorizontalAction = [SKAction moveToX:[self positionXAtMapX:x] duration:[self moveDurationAcrossTiles:tileCountX AtSpeed:movementSpeed]];
    
    SKAction *unitMoveVerticalAction = [SKAction moveToY:[self positionYAtMapY:y] duration:[self moveDurationAcrossTiles:tileCountY AtSpeed:movementSpeed]];
    
    SKAction *unitMoveDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Move Completed");
        /*
        [self removeLastRallyPoint];
        if ([rallyPointQueue count]<=1)
        {
            [selectedUnit removeAllActions];
        }
        */
    }];
    
    SKAction *unitMoveSequence = [SKAction sequence:@[unitMoveHorizontalAction, unitMoveVerticalAction, unitMoveDoneAction]];
    
    return unitMoveSequence;
    //[selectedUnit runAction:unitMoveSequence withKey:@"isMoving"];
}

-(SKAction*) moveUnitFromStart: (CGPoint)start ToFinish: (CGPoint)finish
{
    int startX = [self mapXatPositionX:start.x];
    int startY = [self mapYatPositionY:start.y];
    int finishX = [self mapXatPositionX:finish.x];
    int finishY = [self mapYatPositionY:finish.y];
    
    int tileCountX = finishX-startX;
    int tileCountY = finishY-startY;
    NSLog(@"start from: %i, %i", startX, startY);
    NSLog(@"finish at: %i, %i", finishX, finishY);
    NSLog(@"distance: %i, %i", tileCountX, tileCountY);
    
    //horizontal and vertical movement is separated
    SKAction *unitMoveHorizontalAction = [SKAction moveToX:finish.x duration:[self moveDurationAcrossTiles:tileCountX AtSpeed:movementSpeed]];
    
    SKAction *unitMoveVerticalAction = [SKAction moveToY:finish.y duration:[self moveDurationAcrossTiles:tileCountY AtSpeed:movementSpeed]];
    
    SKAction *unitMoveDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Move Completed");
    }];
    
    SKAction *unitMoveSequence = [SKAction sequence:@[unitMoveHorizontalAction, unitMoveVerticalAction, unitMoveDoneAction]];
    
    return unitMoveSequence;
}

-(void) executeRallyPointQueue
{
    if ([selectedUnit actionForKey:@"isMoving"])
        return;
    
    NSLog(@"rally point queue: %@", rallyPointQueue);

    NSMutableArray* movementSequence = [[NSMutableArray alloc] init];
    
    /*
     for (id rallyPoint in rallyPointQueue)
    {
        CGPoint destination = [rallyPoint CGPointValue];
        SKAction* movementStep = [self moveUnitToX:[self mapXatPositionX:destination.x] andY:[self mapYatPositionY:destination.y] ];
        [movementSequence addObject: movementStep];
    }
    */
    [rallyPointQueue enumerateObjectsUsingBlock:^(id rallyPoint, NSUInteger idx, BOOL *stop)
    {
        
        if (idx==0)
        {
            SKAction* movementStep = [self moveUnitFromStart:selectedUnit.position ToFinish:[rallyPoint CGPointValue]];
            [movementSequence addObject: movementStep];
        }
        else
        {
            SKAction* movementStep = [self moveUnitFromStart:[[rallyPointQueue objectAtIndex:idx-1] CGPointValue] ToFinish:[rallyPoint CGPointValue]];
            [movementSequence addObject: movementStep];
        }
    }];

    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"All moves completed");
        [rallyPointQueue removeAllObjects];
    }];
    [movementSequence addObject: doneAction];
    
    SKAction *moveAlongRallyPointPath = [SKAction sequence:movementSequence];
    [selectedUnit runAction:moveAlongRallyPointPath withKey:@"isMoving"];
}

-(void) removeLastRallyPoint
{
    [rallyPointQueue removeObjectAtIndex:0];
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

-(void) addTouchIndicatorAtX:(int)x andY: (int)y
{
    [self placeObject:touchIndicatorRoot AtX:x andY:y];
    touchIndicatorRoot.hidden = NO;
}

-(void) addMapTileAtX:(int)x andY: (int)y
{
    
    //KKSpriteNode* mapTile = [KKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(tileWidth, tileWidth)];
    
    KKShapeNode* tileOutline = [KKShapeNode node];
    tileOutline.name = @"tile";
    CGMutablePathRef tileOutlinePath = CGPathCreateMutable();
    CGPathAddRect(tileOutlinePath, NULL, CGRectMake(-tileWidth/2, -tileWidth/2, tileWidth, tileWidth));
    tileOutline.path = tileOutlinePath;
    tileOutline.lineWidth = 1.0;
    tileOutline.fillColor = [SKColor clearColor];
    tileOutline.strokeColor = [SKColor whiteColor];
    tileOutline.glowWidth = 0.0;
    tileOutline.hidden = YES;
    /*
    [mapTile addChild:tileOutline];
    mapTile.position = [self positionAtMapX:x andY:y];
    [mapRoot addChild:mapTile];
     */
    
    tileOutline.position = [self positionAtMapX:x andY:y];
    [mapRoot addChild:tileOutline];
    
    [mapTiles addObject:tileOutline];
}

-(void)highlightTile: (KKNode*)mapTile
{
    
}

-(void) update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
    
    //hide tile outlines as unit moves over them
    [mapRoot enumerateChildNodesWithName:@"tile" usingBlock:^(SKNode *node, BOOL *stop)
    {
        if ([selectedUnit intersectsNode:node])
        {
            node.hidden = YES;
        }
	}];
    
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/* Called when a touch begins */
	
	for (UITouch* touch in touches)
	{
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if (n != self && [n.name isEqual: @"unit"]) {
            NSLog(@"touched unit");
            
            canSetRallyPoints = YES;
        }
	}
	
	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
	{
        CGPoint location = [touch locationInNode:mapRoot];
        NSLog(@"touch moved: %f, %f",location.x, location.y);
        float gridX = floorf((location.x/tileWidth));
        float gridY = floorf((location.y/tileWidth));
        //[self addTouchIndicatorAtX:gridX andY:gridY];
        
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if (n != self && [n.name isEqual: @"tile"]) {
            NSLog(@"touched tile");
            
            if (canSetRallyPoints && ![selectedUnit actionForKey:@"isMoving"] && n.hidden)
            {
                [rallyPointQueue addObject:[NSValue valueWithCGPoint:n.position]];
                n.hidden = NO;
            }
            
        }
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
	{
        CGPoint location = [touch locationInNode:mapRoot];
        NSLog(@"touch moved: %f, %f",location.x, location.y);
        float gridX = floorf((location.x/tileWidth));
        float gridY = floorf((location.y/tileWidth));
        [self addTouchIndicatorAtX:gridX andY:gridY];
    }
    
    canSetRallyPoints = NO;
    [self executeRallyPointQueue];
}


@end
