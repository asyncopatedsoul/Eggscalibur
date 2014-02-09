//
//  EHMechUnit.m
//  Eggscalibur
//
//  Created by Michael Garrido on 1/28/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECMechUnit.h"
#import "ECBarIndicator.h"
#import "ECPlayer.h"

@implementation ECMechUnit

-(id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

-(id) initWithProperties:(NSArray*)properties Owner:(ECPlayer*)player OnMap:(ECMap*)_map
{
    self = [super init];
    
    if (self)
    {
        owner = player;
        map = _map;
        
        [self setup];
    }
    
    return self;
}

-(void) setup
{
    float unitWidth = 40.0;

    movementRange = 5;
    willReceiveRallyPoints = YES;
    
    movementSpeed = 5.0;
    movementCost = 50.0;
    rallyPointQueue = [[NSMutableArray alloc] init];
    
    energyMax = 1000.0;
    energyLevel = 1000.0;
    
    healthMax = 1000.0;
    healthLevel = 1000.0;
    
    self.name = @"unit";
    
    unitBody = [KKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(unitWidth, unitWidth)];
    unitBody.name = @"unitBody";
    unitBody.physicsBody.dynamic = YES;
    unitBody.physicsBody.restitution = 0.2;
    unitBody.physicsBody.allowsRotation = YES;
    unitBody.physicsBody.mass = 1.0;
    
    unitBodyAura = [KKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(unitWidth*2, unitWidth*2)];
    unitBodyAura.name = @"unitBodyAura";
    unitBodyAura.hidden = YES;
    
    unitTouchMask = [KKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(unitWidth, unitWidth)];
    unitTouchMask.name = @"unitTouchMask";
    
    // setup energy and health indicators
    
    energyIndicator = [[ECBarIndicator alloc]initWithSize:CGSizeMake(kUnitIndicatorBarWidth,kUnitIndicatorBarHeight) Color:[UIColor yellowColor] MaxValue:energyMax];
    energyIndicator.position = CGPointMake(0.0,40.0);
    
    healthIndicator = [[ECBarIndicator alloc]initWithSize:CGSizeMake(kUnitIndicatorBarWidth,kUnitIndicatorBarHeight) Color:[UIColor yellowColor] MaxValue:energyMax];
    healthIndicator.position = CGPointMake(0.0,50.0);
    
    // setup unit facing direction
    
    facingDirection = [KKShapeNode node];
    facingDirection.position = CGPointMake(-10.0, -10.0);
    CGPoint triangle[] = {CGPointMake(0.0, 0.0), CGPointMake(10.0, 20.0), CGPointMake(20.0, 0.0)};
    CGMutablePathRef facingPointer = CGPathCreateMutable();
    CGPathAddLines(facingPointer, NULL, triangle, 3);
    facingDirection.path = facingPointer;
    facingDirection.lineWidth = 1.0;
    facingDirection.fillColor = [SKColor whiteColor];
    facingDirection.strokeColor = [SKColor clearColor];
    facingDirection.glowWidth = 0.0;
    
    
    // build unit
    [self addChild:energyIndicator];
    [self addChild:healthIndicator];
    [self addChild:unitBody];
    [self addChild:unitBodyAura];
    [self addChild:facingDirection];
    [self addChild:unitTouchMask];
    
    //[self addObject:(KKNode*)selectedUnit ToMapAtX:1 andY:5];
}

-(bool) checkIfIntersectsWithNode:(SKNode*)node
{
    if ([node intersectsNode:[self childNodeWithName:@"unitTouchMask"]])
    {
        NSLog(@"player %i unit touched",owner.userId);
        return true;
    }
    else
    {
        return false;
    }
    
}

-(void) executeRallyPointQueue
{
    if ([self actionForKey:@"isMoving"] || !willReceiveRallyPoints)
        return;
    
    willReceiveRallyPoints = NO;
    
    NSLog(@"rally point queue: %@", rallyPointQueue);
    
    NSMutableArray* movementSequence = [[NSMutableArray alloc] init];
    
    [rallyPointQueue enumerateObjectsUsingBlock:^(id rallyPoint, NSUInteger idx, BOOL *stop)
     {
         
         if (idx==0)
         {
             SKAction* movementStep = [self moveFromStart:self.position ToFinish:[rallyPoint CGPointValue]];
             [movementSequence addObject: movementStep];
         }
         else
         {
             SKAction* movementStep = [self moveFromStart:[[rallyPointQueue objectAtIndex:idx-1] CGPointValue] ToFinish:[rallyPoint CGPointValue]];
             [movementSequence addObject: movementStep];
         }
     }];
    
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"All moves completed");
        [rallyPointQueue removeAllObjects];
        willReceiveRallyPoints = YES;
    }];
    [movementSequence addObject: doneAction];
    
    SKAction *moveAlongRallyPointPath = [SKAction sequence:movementSequence];
    [self runAction:moveAlongRallyPointPath withKey:@"isMoving"];
}

-(bool) validateRallyPoint:(CGPoint)newRallyPoint
{
    CGPoint lastPoint;
    // get position to validate against
    if ([rallyPointQueue count]==0)
    {
        lastPoint = [self position];
    }
    else
    {
        lastPoint = [[rallyPointQueue lastObject] CGPointValue];
    }
    
    if (newRallyPoint.x==lastPoint.x)
    {
        if (newRallyPoint.y>lastPoint.y+kTileWidth||newRallyPoint.y<lastPoint.y-kTileWidth)
            return false;
        else
            return true;
    }
    else if (newRallyPoint.y==lastPoint.y)
    {
        if (newRallyPoint.x>lastPoint.x+kTileWidth||newRallyPoint.x<lastPoint.x-kTileWidth)
            return false;
        else
            return true;
    }
    else {
        return false;
    }
}

-(SKAction*) moveFromStart: (CGPoint)start ToFinish: (CGPoint)finish
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
    
    float horizontalRotation = (tileCountX>0)?-M_PI/2:M_PI/2;
    float verticalRotation = (tileCountY>0)?0:M_PI;
    
    // horizontal and vertical movement is separated
    //SKAction* unitFaceHorizontalAction = [SKAction rotateByAngle:M_PI duration:1.0];
    SKAction* unitFaceHorizontalAction = [SKAction rotateToAngle:horizontalRotation duration:0.1 shortestUnitArc:YES];
    SKAction *unitFaceHorizontalChildAction = [SKAction runBlock:(dispatch_block_t)^() {
        [unitBody runAction:unitFaceHorizontalAction];
    }];
    
    SKAction *unitMoveHorizontalAction = [SKAction moveToX:finish.x duration:[self moveDurationAcrossTiles:tileCountX AtSpeed:movementSpeed]];
    
    //SKAction* unitFaceVerticalAction = [SKAction rotateByAngle:M_PI duration:1.0];
    SKAction* unitFaceVerticalAction = [SKAction rotateToAngle:verticalRotation duration:0.1 shortestUnitArc:YES];
    SKAction *unitFaceVerticalChildAction = [SKAction runBlock:(dispatch_block_t)^() {
        [unitBody runAction:unitFaceVerticalAction];
    }];
    
    SKAction *unitMoveVerticalAction = [SKAction moveToY:finish.y duration:[self moveDurationAcrossTiles:tileCountY AtSpeed:movementSpeed]];
    
    SKAction *unitMoveDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Move Completed");
        NSLog(@"energy level: %f", energyLevel);
        NSLog(@"root rotation: %f",self.zRotation);
        NSLog(@"body rotation: %f",unitBody.zRotation);
        
        [self unitMovedWithEnergy];
        
        // check if unit has enough energy to move again
        if (energyLevel-movementCost < 0){
            [self cancelUnitMovement];
            [self showUnitHasInsufficientEnergy];
            willReceiveRallyPoints = NO;
        }
    }];
    
    NSMutableArray* unitMoveSequence = [[NSMutableArray alloc] init];
    
    if (tileCountX!=0)
    {
        NSLog(@"horizontal rotation: %f",horizontalRotation);
        //[unitMoveSequence addObject:unitFaceHorizontalAction];
        [unitMoveSequence addObject:unitFaceHorizontalChildAction];
        [unitMoveSequence addObject:unitMoveHorizontalAction];
    }
    if (tileCountY!=0)
    {
        NSLog(@"vertical rotation: %f",verticalRotation);
        //[unitMoveSequence addObject:unitFaceVerticalAction];
        [unitMoveSequence addObject:unitFaceVerticalChildAction];
        [unitMoveSequence addObject:unitMoveVerticalAction];
    }
    
    [unitMoveSequence addObject:unitMoveDoneAction];
    
    NSLog(@"move sequence: %@",unitMoveSequence);
    
    SKAction *unitMoveSequenceAction = [SKAction sequence:unitMoveSequence];
    
    return unitMoveSequenceAction;
}

-(SKAction*) moveUnitToX:(int)x andY: (int)y
{
    //TODO calculate duration from unit's movement speed
    int tileCountX = x-[self mapXatCurrentPosition];
    int tileCountY = y-[self mapYAtCurrentPosition];
    NSLog(@"moving by tiles: %i, %i", tileCountX, tileCountY);
    
    //horizontal and vertical movement is separated
    SKAction *unitMoveHorizontalAction = [SKAction moveToX:[self positionXAtMapX:x] duration:[self moveDurationAcrossTiles:tileCountX AtSpeed:movementSpeed]];
    
    SKAction *unitMoveVerticalAction = [SKAction moveToY:[self positionYAtMapY:y] duration:[self moveDurationAcrossTiles:tileCountY AtSpeed:movementSpeed]];
    
    SKAction *unitMoveDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Move Completed");
        
    }];
    
    SKAction *unitMoveSequence = [SKAction sequence:@[unitMoveHorizontalAction, unitMoveVerticalAction, unitMoveDoneAction]];
    
    return unitMoveSequence;
    //[selectedUnit runAction:unitMoveSequence withKey:@"isMoving"];
}


-(void) removeLastRallyPoint
{
    [rallyPointQueue removeObjectAtIndex:0];
}

-(void) cancelUnitMovement
{
    [self removeActionForKey:@"isMoving"];
    [rallyPointQueue removeAllObjects];
    
    
    [map enumerateChildNodesWithName:@"tile" usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node childNodeWithName:@"tileMask"].hidden = YES;
         [node childNodeWithName:@"tileOutline"].hidden = YES;
     }];
}
/*
-(void) unitCapturedTile:(KKNode*)tile
{
    int playerId = [[selectedUnit.userData valueForKey:@"ownerId"] intValue];
    
    // derive energy amount added from tile
    float energyAmount = [self setOwner:playerId ForTile:(KKSpriteNode*)tile];
    
    [self addEnergy:energyAmount ToPlayer:playerId];
    
    [tile childNodeWithName:@"tileMask"].hidden = YES;
    [tile childNodeWithName:@"tileOutline"].hidden = YES;
    
    //[self updateEnergyIndicatorAtSpeed:0.5];
}
*/
#pragma mark energy

-(void) showUnitHasInsufficientEnergy
{
    unitBody.color = [UIColor redColor];
}

-(void) unitMovedWithEnergy
{
    [self updateUnitEnergy:-movementCost AtSpeed:movementSpeed];
}

-(bool) addEnergy:(float)energyAmount ToUnit:(KKNode*)unit
{
    if (energyLevel==energyMax){
        NSLog(@"unit fully charged");
        return false;
    }
    if (energyLevel+energyAmount>energyMax){
        energyAmount = energyMax-energyLevel;
    }
    
    [self updateUnitEnergy:energyAmount AtSpeed:0.2];
    return true;
}

-(float) updateUnitEnergy: (float)energyAmount AtSpeed:(float)speed
{
    energyLevel+=energyAmount;
    [self updateEnergyIndicatorAtSpeed:speed];
    
    return energyLevel;
}

-(void) updateEnergyIndicatorAtSpeed: (float)speed
{
    //SKAction *resizeIndicator = [SKAction resizeToWidth:indicatorBarWidth*(energyLevel/energyMax) duration:0.1];
    //[energyIndicator runAction:resizeIndicator];
}

-(void) beginChargingUnit:(KKNode*)unit
{
    // show unit is charging
    unitBody.color = [UIColor yellowColor];
    unitBodyAura.hidden = NO;
    
    float unitChargeSpeed = 0.5;
    
    SKAction *addEnergyAction = [SKAction runBlock:(dispatch_block_t)^() {
        [owner transferEnergyFromPlayerToUnit:unit];
    }];
    
    SKAction *blink = [SKAction sequence:@[addEnergyAction,
                                           [SKAction fadeOutWithDuration:unitChargeSpeed/2],
                                           [SKAction fadeInWithDuration:unitChargeSpeed/2]]];
    SKAction *blinkForever = [SKAction repeatActionForever:blink];
    [unitBodyAura runAction:blinkForever withKey:@"unitCharging"];
}

-(void) finishChargingUnit:(KKNode*)unit
{
    unitBody.color = [UIColor blueColor];
    
    [unitBodyAura removeActionForKey:@"unitCharging"];
    unitBodyAura.alpha = 1.0;
    unitBodyAura.hidden = YES;
}

#pragma mark health

-(float) updateUnitHealth: (float)healthAmount AtSpeed:(float)speed
{
    healthLevel+=healthAmount;
    [self updateEnergyIndicatorAtSpeed:speed];
    
    return energyLevel;
}


@end
