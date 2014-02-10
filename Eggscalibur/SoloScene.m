//
//  SoloScene.m
//  Eggscalibur
//
//  Created by Michael Garrido on 1/26/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "SoloScene.h"
#import "ECMap.h"
#import "ECPlayer.h"
#import "ECMechUnit.h"
#import "ECFactoryUnit.h"
#import "ECTile.h"
#import "ECPlayerHUD.h"

@implementation SoloScene
{
    // map
    ECMap* map;
    
    // camera movement
    KKNode* cameraRoot;
    CGPoint touchOrigin;
    CGPoint touchDestination;
    
    bool willSetRallyPoints;
    
    int currentPlayerGameId;
    
    // rally point management
    ECMechUnit* selectedUnit;
    
    KKNode* HUDRoot;
    /*
    float tileWidth;
    int mapWidth;
    KKNode* mapRoot;
    NSMutableArray* mapTiles;
    
    
    KKSpriteNode* selectedUnitBody;
    KKNode* touchIndicatorRoot;
   
    bool canSetRallyPoints;
    
    
    // player energy
   
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
     */
}

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		self.backgroundColor = [SKColor blackColor];
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = self;
        
        willSetRallyPoints = NO;
        
        // unit template
        NSDictionary* factoryUnit = @{ @"type" : @1 };
        NSDictionary* battleUnit = @{ @"type" : @2 };
        // a deck must have at least 1 factory unit and 1 battle unit
        NSArray* deck = [[NSArray alloc] initWithObjects:factoryUnit, battleUnit, nil];
        
        
        // setup map
        map = [[ECMap alloc] init];
        [self addChild:map];
        
        // setup players
        ECPlayer* player1 = [[ECPlayer alloc] initWithName:@"Mike" Id:0 Deck:deck];
        ECPlayer* player2 = [[ECPlayer alloc] initWithName:@"Karlo" Id:1 Deck:deck];
        
        players = [[NSMutableArray alloc] init];
        [players addObject:player1];
        [players addObject:player2];
        
        
		// TODO which player is this?
        // maps to unit.gameId
        currentPlayerGameId = 0;

        
        // setup units
        [self setupUnits];
        
        // setup camera
        [self setupCamera];
        
        // setup HUD
        [self setupHUD];
	}
	return self;
}

-(void) setupUnits
{
    // TODO get start locations from map properties
    NSArray* factoryStartLocations = [[NSArray alloc] initWithObjects:@{ @"x": @0, @"y":@0}, @{ @"x": @9, @"y":@9}, nil];
    
    // loop through players
    [players enumerateObjectsUsingBlock:^(id _player, NSUInteger idx, BOOL *stop) {
        
        ECPlayer* player = (ECPlayer*)_player;
        
        // take factory unit from deck and create it
        ECMechUnit* factoryUnit = [[ECMechUnit alloc] initWithProperties:[player.deck objectAtIndex:0] Owner:player OnMap:map];
        
        id startLocation = [factoryStartLocations objectAtIndex:idx];
        
        [map addUnit:factoryUnit ToMapAtX:[[startLocation objectForKey:@"x"] intValue] andY:[[startLocation objectForKey:@"y"] intValue]];
        
    }];
    
}

-(void) setupHUD
{
    ECPlayerHUD* HUD = [[ECPlayerHUD alloc] init];
    [self addChild:HUD];
    
    for (id _player in players)
    {
        ECPlayer* player = (ECPlayer*)_player;
        
        // loop through player's units
        for (id _unit in player.deck)
        {
            
        }
    }
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
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    //[view addGestureRecognizer:pinchGesture];
}

-(void) update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
    
    //hide tile outlines as unit moves over them
    [map enumerateChildNodesWithName:@"tile" usingBlock:^(SKNode *node, BOOL *stop)
    {
        if ([selectedUnit intersectsNode:node])
        {
            ECTile* tile = (ECTile*)node;
            [tile deactivateAsRallyPointForUnit:selectedUnit];
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
        
        if (n != self && [n.name isEqual: @"unitTouchMask"]) {
            ECMechUnit* unit = (ECMechUnit*) n.parent;
            if ([unit checkIfIntersectsWithNode:n ByPlayer:currentPlayerGameId])
            {
                NSLog(@"player unit selected");
                selectedUnit = unit;
                unit.willReceiveRallyPoints = YES;
                //willSetRallyPoints = YES;
            }
        }
        
        // check if player owns that unit
        /*
        [map.units enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            ECMechUnit* unit = (ECMechUnit*) object;
            if ([unit checkIfIntersectsWithNode:n ByPlayer:currentPlayerGameId])
            {
                NSLog(@"player unit selected");
                selectedUnit = unit;
                willSetRallyPoints = YES;
            }
        }];
         */
        
        
        /*
        if ([n intersectsNode:[selectedUnit childNodeWithName:@"unitMask"]])
        {
            NSLog(@"touched unit");
            
            if ([selectedUnit actionForKey:@"isMoving"])
            {
                // immediately stop unit
                //[self cancelUnitMovement];
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
         */
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
        CGPoint location = [touch locationInNode:map];
        NSLog(@"single touch moved: %f, %f",location.x, location.y);
        
        
        SKNode *n = [self nodeAtPoint:[touch locationInNode:map]];
        
        //NSLog(@"node name touched: %@", n.name);
        
        NSArray* nodesAtTouch = [[NSArray alloc] initWithArray:[map nodesAtPoint:[touch locationInNode:map]]];
        NSLog(@"map nodes at touch point: %@",nodesAtTouch);
        
        //[nodesAtTouch containsObject:selectedUnit];
        
        ECTile* tile = [map getTileAtLocation:[touch locationInNode:map]];
        
        if (![nodesAtTouch containsObject:selectedUnit.unitTouchMask] && [nodesAtTouch containsObject:tile]) {
        
        //if (n != self && [n.name isEqual: @"tileMask"]) {
            NSLog(@"touched tile");
            
            if (selectedUnit.willReceiveRallyPoints && [selectedUnit validateRallyPoint:tile.position])
            {
                [tile activateAsRallyPointForUnit:selectedUnit];
            }
        }
        
        /*
        
        
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
         */
    }
    else if ([touches count]==2)
    {
        NSLog(@"double touch moved: %f,%f",[touch locationInNode:self].x,[touch locationInNode:self].y);
        
        touchDestination = [touch locationInNode:self];
        float cameraMovementMultiple = 2.0;
        
        float deltaX = (touchDestination.x-touchOrigin.x)*cameraMovementMultiple;
        float deltaY = (touchDestination.y-touchOrigin.y)*cameraMovementMultiple;
        
        float newX = cameraRoot.position.x+deltaX;
        float newY = cameraRoot.position.y+deltaY;
        
        if (newX<-80.0){
            newX=-80.0;
        }else if (newX>20.0){
            newX=20.0;
        }
        
        if (newY>260.0){
            newY=260.0;
        } else if (newY<-80.0){
            newY=-80.0;
        }
        
        CGPoint newCameraPosition = CGPointMake(newX,newY);
        cameraRoot.position = newCameraPosition;
        NSLog(@"new camera position: %f,%f",newCameraPosition.x,newCameraPosition.y);
        
        touchOrigin = [touch locationInNode:self];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
	{
        
        if (selectedUnit.willReceiveRallyPoints)
        {
            CGPoint location = [touch locationInNode:map];
            NSLog(@"touch ended: %f, %f",location.x, location.y);
            
            [selectedUnit executeRallyPointQueue];
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
            //[self beginChargingUnit:selectedUnit];
        }
    }
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        NSLog(@"long press changed");
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"long press ended");
        //[self finishChargingUnit:selectedUnit];
    }
}

- (void) handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    NSLog(@"handlePinchGesture: %f",recognizer.scale);
    
    //recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    
    if (recognizer.scale>1)
    {
        map.xScale = 1.0;
        map.yScale = 1.0;
    }
    else if (recognizer.scale<1)
    {
        map.xScale = 0.5;
        map.yScale = 0.5;
    }
    
    //recognizer.scale = 1;
    
}

#pragma mark camera movement

-(void) setupCamera
{
    touchOrigin = CGPointZero;
    cameraRoot = [KKNode node];
    cameraRoot.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    if (currentPlayerGameId==0)
    {
        // position camera in bottom left
        cameraRoot.position = CGPointMake(-80.0,0.0);
    }
    

    [map addChild:cameraRoot];
    
    // TODO set camera on factory starting position
}

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
