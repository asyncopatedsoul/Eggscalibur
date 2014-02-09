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

@implementation SoloScene
{
    // map
    ECMap* map;
    
    // camera movement
    KKNode* cameraRoot;
    CGPoint touchOrigin;
    CGPoint touchDestination;
    
    bool willSetRallyPoints;
    
    float tileWidth;
    int mapWidth;
    KKNode* mapRoot;
    NSMutableArray* mapTiles;
    
    // rally point management
    KKNode* selectedUnit;
    KKSpriteNode* selectedUnitBody;
    KKNode* touchIndicatorRoot;
   
    bool canSetRallyPoints;
    
    
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
        
        // unit template
        NSDictionary* factoryUnit = @{ @"type" : @1 };
        NSDictionary* battleUnit = @{ @"type" : @2 };
        // a deck must have at least 1 factory unit and 1 battle unit
        NSArray* deck = [[NSArray alloc] initWithObjects:factoryUnit, battleUnit, nil];
        
        
        // setup map
        map = [[ECMap alloc] init];
        [self addChild:map];
        
        // setup players
        ECPlayer* player1 = [[ECPlayer alloc] initWithName:@"Mike" Id:1 Deck:deck];
        ECPlayer* player2 = [[ECPlayer alloc] initWithName:@"Karlo" Id:2 Deck:deck];
        
        players = [[NSMutableArray alloc] init];
        [players addObject:player1];
        [players addObject:player2];
        
        // setup HUD
        
        
        // setup units
        [self setupUnits];
        
        // setup camera
        
        //[self renderMap];
		//[self setupPlayerHUD];
        [self setupCamera];
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
    [mapRoot enumerateChildNodesWithName:@"tile" usingBlock:^(SKNode *node, BOOL *stop)
    {
        if ([selectedUnit intersectsNode:node])
        {
            if ([node childNodeWithName:@"tileMask"].hidden == NO)
            {
                NSLog(@"unit moved over tile");
                //[self unitCapturedTile:(KKNode*)node];
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
        
        // check if player owns that unit
        [map.units enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            ECMechUnit* unit = (ECMechUnit*) object;
            [unit checkIfIntersectsWithNode:n];
        }];
        
        
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
        
        if (willSetRallyPoints)
        {
            CGPoint location = [touch locationInNode:map];
            NSLog(@"touch moved: %f, %f",location.x, location.y);
            
            //[self executeRallyPointQueue];
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
    
    playerHUDRoot = [KKNode node];
    KKSpriteNode* testUI = [KKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(80, 320.0)];
    testUI.position = CGPointMake(40.,160.0);
    [playerHUDRoot addChild:testUI];
    //[self addChild:playerHUDRoot];
    
    [map addChild:cameraRoot];
    
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
