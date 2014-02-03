//
//  EHMechUnit.m
//  Eggscalibur
//
//  Created by Michael Garrido on 1/28/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECMechUnit.h"

@implementation ECMechUnit

-(void) setup
{
    // energy bar
    // health bar
    
    // link player
    // link map
}

-(void) setupUnits
{
    float unitWidth = 40.0;
    
    indicatorBarWidth = 30.0;
    maxUnitMovementDistance = 5;
    canSetRallyPoints = YES;
    
    // player's squad
    selectedUnit  = [KKNode node];
    
    selectedUnit.userData = [[NSMutableDictionary alloc] init];
    [selectedUnit.userData setValue:[NSNumber numberWithInt:1] forKey:@"ownerId"];
    
    selectedUnitBody = [KKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(unitWidth, unitWidth)];
    selectedUnitBody.name = @"unitBody";
    selectedUnitBody.physicsBody.dynamic = YES;
    selectedUnitBody.physicsBody.restitution = 0.2;
    selectedUnitBody.physicsBody.allowsRotation = YES;
    selectedUnitBody.physicsBody.mass = 0.0;
    
    KKSpriteNode* unitBodyAura = [KKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(unitWidth*2, unitWidth*2)];
    unitBodyAura.name = @"unitBodyAura";
    unitBodyAura.hidden = YES;
    
    KKSpriteNode* unitMask = [KKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(unitWidth, unitWidth)];
    unitMask.name = @"unitMask";
    
    energyIndicator = [KKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(indicatorBarWidth, 5.0)];
    energyIndicator.position = CGPointMake(0.0,40.0);
    
    // setup unit facing direction
    
    KKShapeNode* faceDirection = [KKShapeNode node];
    faceDirection.position = CGPointMake(-10.0, -10.0);
    CGPoint triangle[] = {CGPointMake(0.0, 0.0), CGPointMake(10.0, 20.0), CGPointMake(20.0, 0.0)};
    CGMutablePathRef facingPointer = CGPathCreateMutable();
    CGPathAddLines(facingPointer, NULL, triangle, 3);
    faceDirection.path = facingPointer;
    faceDirection.lineWidth = 1.0;
    faceDirection.fillColor = [SKColor whiteColor];
    faceDirection.strokeColor = [SKColor clearColor];
    faceDirection.glowWidth = 0.0;
    
    energyMax = 1000.0;
    energyLevel = 1000.0;
    movementSpeed = 5.0;
    movementCost = 50.0;
    rallyPointQueue = [[NSMutableArray alloc] init];
    
    // build unit
    [selectedUnit addChild:energyIndicator];
    [selectedUnit addChild:selectedUnitBody];
    [selectedUnit addChild:unitBodyAura];
    [selectedUnitBody addChild:faceDirection];
    [selectedUnit addChild:unitMask];
    
    [self addObject:(KKNode*)selectedUnit ToMapAtX:1 andY:5];
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
        lastPoint = [selectedUnit position];
    }
    else
    {
        lastPoint = [[rallyPointQueue lastObject] CGPointValue];
    }
    
    if (newRallyPoint.x==lastPoint.x)
    {
        if (newRallyPoint.y>lastPoint.y+tileWidth||newRallyPoint.y<lastPoint.y-tileWidth)
            return false;
        else
            return true;
    }
    else if (newRallyPoint.y==lastPoint.y)
    {
        if (newRallyPoint.x>lastPoint.x+tileWidth||newRallyPoint.x<lastPoint.x-tileWidth)
            return false;
        else
            return true;
    }
    else {
        return false;
    }
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
    
    float horizontalRotation = (tileCountX>0)?-M_PI/2:M_PI/2;
    float verticalRotation = (tileCountY>0)?0:M_PI;
    
    // horizontal and vertical movement is separated
    //SKAction* unitFaceHorizontalAction = [SKAction rotateByAngle:M_PI duration:1.0];
    SKAction* unitFaceHorizontalAction = [SKAction rotateToAngle:horizontalRotation duration:0.1 shortestUnitArc:YES];
    SKAction *unitFaceHorizontalChildAction = [SKAction runBlock:(dispatch_block_t)^() {
        [selectedUnitBody runAction:unitFaceHorizontalAction];
    }];
    
    SKAction *unitMoveHorizontalAction = [SKAction moveToX:finish.x duration:[self moveDurationAcrossTiles:tileCountX AtSpeed:movementSpeed]];
    
    //SKAction* unitFaceVerticalAction = [SKAction rotateByAngle:M_PI duration:1.0];
    SKAction* unitFaceVerticalAction = [SKAction rotateToAngle:verticalRotation duration:0.1 shortestUnitArc:YES];
    SKAction *unitFaceVerticalChildAction = [SKAction runBlock:(dispatch_block_t)^() {
        [selectedUnitBody runAction:unitFaceVerticalAction];
    }];
    
    SKAction *unitMoveVerticalAction = [SKAction moveToY:finish.y duration:[self moveDurationAcrossTiles:tileCountY AtSpeed:movementSpeed]];
    
    SKAction *unitMoveDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Move Completed");
        NSLog(@"energy level: %f", energyLevel);
        NSLog(@"root rotation: %f",selectedUnit.zRotation);
        NSLog(@"body rotation: %f",selectedUnitBody.zRotation);
        
        [self unitMovedWithEnergy];
        
        // check if unit has enough energy to move again
        if (energyLevel-movementCost < 0){
            [self cancelUnitMovement];
            [self showUnitHasInsufficientEnergy];
            canSetRallyPoints = NO;
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
    int tileCountX = x-[self mapXForNode:(KKNode*)selectedUnit];
    int tileCountY = y-[self mapYForNode:(KKNode*)selectedUnit];
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
    [selectedUnit removeActionForKey:@"isMoving"];
    [rallyPointQueue removeAllObjects];
    
    [mapRoot enumerateChildNodesWithName:@"tile" usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node childNodeWithName:@"tileMask"].hidden = YES;
         [node childNodeWithName:@"tileOutline"].hidden = YES;
     }];
}

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

#pragma mark energy

-(void) showUnitHasInsufficientEnergy
{
    selectedUnitBody.color = [UIColor redColor];
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

-(void) updateUnitEnergy: (float)energyAmount AtSpeed:(float)speed
{
    energyLevel+=energyAmount;
    [self updateEnergyIndicatorAtSpeed:speed];
}

-(void) updateEnergyIndicatorAtSpeed: (float)speed
{
    SKAction *resizeIndicator = [SKAction resizeToWidth:indicatorBarWidth*(energyLevel/energyMax) duration:0.1];
    [energyIndicator runAction:resizeIndicator];
}

-(void) beginChargingUnit:(KKNode*)unit
{
    // show unit is charging
    KKSpriteNode* unitBody = (KKSpriteNode*)[unit childNodeWithName:@"unitBody"];
    unitBody.color = [UIColor yellowColor];
    KKSpriteNode* unitBodyAura = (KKSpriteNode*)[unit childNodeWithName:@"unitBodyAura"];
    unitBodyAura.hidden = NO;
    
    float unitChargeSpeed = 0.5;
    
    SKAction *addEnergyAction = [SKAction runBlock:(dispatch_block_t)^() {
        [self transferEnergyFromPlayerToUnit:unit];
    }];
    
    SKAction *blink = [SKAction sequence:@[addEnergyAction,
                                           [SKAction fadeOutWithDuration:unitChargeSpeed/2],
                                           [SKAction fadeInWithDuration:unitChargeSpeed/2]]];
    SKAction *blinkForever = [SKAction repeatActionForever:blink];
    [unitBodyAura runAction:blinkForever withKey:@"unitCharging"];
}

-(void) finishChargingUnit:(KKNode*)unit
{
    KKSpriteNode* unitBody = (KKSpriteNode*)[unit childNodeWithName:@"unitBody"];
    KKSpriteNode* unitBodyAura = (KKSpriteNode*)[unit childNodeWithName:@"unitBodyAura"];
    
    unitBody.color = [UIColor blueColor];
    
    [unitBodyAura removeActionForKey:@"unitCharging"];
    unitBodyAura.alpha = 1.0;
    unitBodyAura.hidden = YES;
}


@end
