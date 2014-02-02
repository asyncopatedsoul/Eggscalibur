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
    int mapWidth;
    KKNode* mapRoot;
    NSMutableArray* mapTiles;
    
    // camera movement
    KKNode* cameraRoot;
    CGPoint touchOrigin;
    CGPoint touchDestination;
    
    // rally point management
    KKNode* selectedUnit;
    KKSpriteNode* selectedUnitBody;
    KKNode* touchIndicatorRoot;
   
    bool canSetRallyPoints;
    bool willSetRallyPoints;
    
    // player energy
    KKNode* playerHUDRoot;
    KKSpriteNode* playerEnergyLevelIndicator;
    KKLabelNode* playerEnergyCount;
    float playerEnergyLevelMaxSize;
    float playerEnergyMax;
    float playerEnergyLevel;
    
    // unit properties
    NSMutableArray* rallyPointQueue;
    int maxUnitMovementDistance;
    float movementSpeed;
    float movementCost;
    float energyLevel;
    float energyMax;
    float energyRechargeSpeed;
    float energyRechargeAmount;
    float indicatorBarWidth;
    KKSpriteNode* energyIndicator;
    
    // battery properties
    float batteryMaxSize;
    float batteryEnergyMax;
    float batteryEnergyLevel;
    KKSpriteNode* batteryLevelIndicator;
}

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		/* Setup your scene here */
		self.backgroundColor = [SKColor blackColor];
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = self;
        
        tileWidth = 50.0;
        canSetRallyPoints = NO;
        
        [self renderMap];
		[self setupPlayerHUD];
        [self setupCamera];
        //[self setupGestureRecognizers];
	}
	return self;
}

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    
    // add gesture recognizers here!
    //http://stackoverflow.com/questions/19040347/uipangesturerecognizer-in-skscene
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [longPressGesture setMinimumPressDuration:0.5];
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.delegate = self;
    [view addGestureRecognizer:longPressGesture];
}

-(void) setupGestureRecognizers
{
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [longPressGesture setMinimumPressDuration:0.5];
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.delegate = self;
    [self.view addGestureRecognizer:longPressGesture];
}

-(void) renderMap
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
    /*
    touchIndicatorRoot = [KKNode node];
    KKSpriteNode* touchIndicator = [KKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(tileWidth, tileWidth)];
    [touchIndicatorRoot addChild:touchIndicator];
    touchIndicatorRoot.hidden = YES;
    [mapRoot addChild:touchIndicatorRoot];
    */
    [self setupUnits];
    [self setupBatteries];
}

-(void) setupCamera
{
    touchOrigin = CGPointZero;
    cameraRoot = [KKNode node];
    cameraRoot.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [mapRoot addChild:cameraRoot];
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

-(void) setupPlayerHUD
{
    /*
     KKNode* playerHUDRoot;
     KKSpriteNode* playerEnergyLevelIndicator;
     float playerEnergyLevelMaxSize;
     float playerEnergyMax;
     float playerEnergyLevel;
     */
    playerEnergyLevelMaxSize = 100.0;
    playerEnergyMax = 1000.0;
    playerEnergyLevel = 0.0;
    float playerEnergyLevelIndicatorHeight = 20.0;
    
    playerHUDRoot = [KKNode node];
    playerHUDRoot.zPosition = 1000;
    
    playerEnergyLevelIndicator = [KKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(0.0, playerEnergyLevelIndicatorHeight)];
    playerEnergyCount = [KKLabelNode node];
    
    //HUD anchored in top left corner
    playerEnergyLevelIndicator.position = CGPointMake(playerEnergyLevelMaxSize/2,0.0);
    playerEnergyCount.position = CGPointMake(playerEnergyLevelMaxSize/2,playerEnergyLevelIndicatorHeight);
    
    [playerHUDRoot addChild:playerEnergyLevelIndicator];
    [playerHUDRoot addChild:playerEnergyCount];
    
    [self addChild:playerHUDRoot];
}

-(void) unitCapturedTile:(KKNode*)tile
{
    int playerId = [[selectedUnit.userData valueForKey:@"ownerId"] intValue];
    
    // derive energy amount added from tile
    float energyAmount = [self setOwner:playerId ForTile:(KKSpriteNode*)tile];
    
    [self addEnergy:energyAmount ToPlayer:playerId];
    
    [tile childNodeWithName:@"tileMask"].hidden = YES;
    [tile childNodeWithName:@"tileOutline"].hidden = YES;
    
    [self updateEnergyIndicatorAtSpeed:0.5];
}

-(void) updatePlayerEnergyIndicatorAtSpeed: (float)speed
{
    playerEnergyCount.text = [NSString stringWithFormat:@"%i",[[NSNumber numberWithFloat:playerEnergyLevel] intValue]];
    
    SKAction *resizeIndicator = [SKAction resizeToWidth:playerEnergyLevelMaxSize*(playerEnergyLevel/playerEnergyMax) duration:speed];
    [playerEnergyLevelIndicator runAction:resizeIndicator];
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

-(void) addEnergy:(float)energyAmount ToPlayer:(int)playerId
{
    if (playerId == 1)
    {
        playerEnergyLevel+=energyAmount;
        [self updatePlayerEnergyIndicatorAtSpeed:0.1];
    }
}

-(bool) removeEnergy:(float)energyAmount FromPlayer:(int)playerId
{
    if (playerEnergyLevel-energyAmount<0)
    {
        NSLog(@"player has insufficient energy");
        return false;
    }
    else
    {
        playerEnergyLevel-=energyAmount;
        [self updatePlayerEnergyIndicatorAtSpeed:0.1];
        return true;
    }
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

-(void) beginChargingUnit:(KKNode*)unit
{
    // show unit is charging
    KKSpriteNode* unitBody = (KKSpriteNode*)[unit childNodeWithName:@"unitBody"];
    unitBody.color = [UIColor yellowColor];
    KKSpriteNode* unitBodyAura = (KKSpriteNode*)[unit childNodeWithName:@"unitBodyAura"];
    unitBodyAura.hidden = NO;
    
    float unitChargeSpeed = 0.5;
    float unitChargeAmount = 50.0; // TODO should equal to unit movement cost?
    
    SKAction *addEnergyAction = [SKAction runBlock:(dispatch_block_t)^() {
        
        if ([self removeEnergy:unitChargeAmount FromPlayer:[[unit.userData valueForKey:@"ownerId"] integerValue]])
            [self addEnergy:unitChargeAmount ToUnit:unit];
        
        if (energyLevel>=movementCost)
            canSetRallyPoints = YES;
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

-(void) setupBatteries
{
    [self setupBatteryAtX:5 andY:3];
    [self setupBatteryAtX:2 andY:3];
    [self setupBatteryAtX:7 andY:1];
    [self setupBatteryAtX:6 andY:4];
    [self setupBatteryAtX:1 andY:2];
}

-(void) setupBatteryAtX:(int)x andY:(int)y
{
    KKNode* batteryRoot = [KKNode node];
    
    // battery shell
    KKSpriteNode* batteryShell = [KKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(batteryMaxSize, batteryMaxSize)];
    
    // battery level
    KKSpriteNode* batteryLevelIndicator = [KKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(batteryMaxSize, batteryMaxSize)];
    
    [batteryRoot addChild:batteryShell];
    [batteryRoot addChild:batteryLevelIndicator];
    
    [self addObject:batteryRoot ToMapAtX:x andY:y];
}

-(void) unitMovedWithEnergy
{
    [self updateUnitEnergy:-movementCost AtSpeed:movementSpeed];
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

-(void) showUnitHasInsufficientEnergy
{
    selectedUnitBody.color = [UIColor redColor];
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
    
    if (newRallyPoint.x==lastPoint.x || newRallyPoint.y==lastPoint.y)
        return true;
    else
        return false;
}

-(void) executeRallyPointQueue
{
    if ([selectedUnit actionForKey:@"isMoving"] || !canSetRallyPoints)
        return;
    
    canSetRallyPoints = NO;
    
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
        canSetRallyPoints = YES;
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

-(void) setLoopMovementPath
{
    NSLog(@"loop formed!");
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
            if ([node childNodeWithName:@"tileMask"].hidden == NO)
            {
                NSLog(@"unit moved over tile");
                [self unitCapturedTile:(KKNode*)node];
            }
        }
	}];
    
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/* Called when a touch begins */
    UITouch* touch = [[touches allObjects] objectAtIndex:0];
    
    if ([touches count]==1)
    {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        
        NSLog(@"single touch began: %f,%f",[touch locationInNode:self].x,[touch locationInNode:self].y);
        
        if ([n intersectsNode:[selectedUnit childNodeWithName:@"unitMask"]])
        {
            NSLog(@"touched unit");
            
            if ([selectedUnit actionForKey:@"isMoving"])
            {
                // immediately stop unit
                [self cancelUnitMovement];
            }
            else
            {
                willSetRallyPoints = YES;
            }
            
        }
        else
        {
            willSetRallyPoints = NO;
        }
    }
    else if ([touches count]==2)
    {
        NSLog(@"double touch began: %f,%f",[touch locationInNode:self].x,[touch locationInNode:self].y);
        touchOrigin = [touch locationInNode:self];
    }
	
	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //for (UITouch* touch in touches){}
    
    UITouch* touch = [[touches allObjects] objectAtIndex:0];
    
    if ([touches count]==1)
    {
        CGPoint location = [touch locationInNode:mapRoot];
        NSLog(@"single touch moved: %f, %f",location.x, location.y);
        
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if (n != self && [n.name isEqual: @"tileMask"]) {
            NSLog(@"touched tile");
            
            if (canSetRallyPoints && willSetRallyPoints && ![selectedUnit actionForKey:@"isMoving"] && n.hidden)
            {
                
                if ([self validateRallyPoint:n.parent.position])
                {
                    NSLog(@"adding rally point");
                    n.hidden = NO;
                    [n.parent childNodeWithName:@"tileOutline"].hidden = NO;
                    
                    
                    [rallyPointQueue addObject:[NSValue valueWithCGPoint:n.parent.position]];
                    if ([rallyPointQueue count]>=maxUnitMovementDistance)
                    {
                        [self executeRallyPointQueue];
                    }
                }
                else
                    NSLog(@"invalid rally point");
                
            }
            
        }
    }
    else if ([touches count]==2)
    {
        NSLog(@"double touch moved: %f,%f",[touch locationInNode:self].x,[touch locationInNode:self].y);
        
        touchDestination = [touch locationInNode:self];
        float deltaX = touchDestination.x-touchOrigin.x;
        float deltaY = touchDestination.y-touchOrigin.y;
        
        CGPoint newCameraPosition = CGPointMake(cameraRoot.position.x+deltaX, cameraRoot.position.y+deltaY);
        cameraRoot.position = newCameraPosition;
        
        touchOrigin = [touch locationInNode:self];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
	{
        
        if (willSetRallyPoints)
        {
            CGPoint location = [touch locationInNode:mapRoot];
            NSLog(@"touch moved: %f, %f",location.x, location.y);
            
            [self executeRallyPointQueue];
            willSetRallyPoints = NO;
        }
        
    }
    
    
}

- (void) handleLongPressGesture: (UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchPoint = [recognizer locationOfTouch:0 inView:self.view];
        NSLog(@"long press began: %f,%f",touchPoint.x,touchPoint.y);
        
        // translate touch location into scene's coordinate system by flipping y value
        touchPoint.y = 320.0-touchPoint.y;
        
        SKNode *n = [self nodeAtPoint:touchPoint];
        if (n != self && [n.name isEqual: @"unitMask"]) {
        
            NSLog(@"long press on unit");
            [self beginChargingUnit:selectedUnit];
        }
    }
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        NSLog(@"long press changed");
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"long press ended");
        [self finishChargingUnit:selectedUnit];
    }
}

#pragma mark camera movement

- (void)didSimulatePhysics
{
    [self centerOnNode: cameraRoot];
    [super didSimulatePhysics];
}

- (void) centerOnNode: (SKNode *) node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y);
}

@end
