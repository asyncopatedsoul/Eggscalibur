//
//  EHMechUnit.h
//  Eggscalibur
//
//  Created by Michael Garrido on 1/28/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"
#import "ECBarIndicator.h"
#import "ECPlayer.h"
#import "ECMap.h"

@interface ECMechUnit : KKSpriteNode
{
    // unit properties
    NSMutableArray* rallyPointQueue;
    bool willReceiveRallyPoints;
    
    int ownerId;
    
    int movementRange;
    float movementSpeed;
    float movementCost;
    
    float energyRechargeSpeed;
    float energyRechargeAmount;
    
    KKSpriteNode* unitBody;
    KKSpriteNode* unitBodyAura;
    KKSpriteNode* unitTouchMask;
    
    KKShapeNode* facingDirection;

    ECBarIndicator* energyIndicator;
    float energyLevel;
    float energyMax;
    
    ECBarIndicator* healthIndicator;
    float healthLevel;
    float healthMax;
    
    ECPlayer* owner;
    ECMap* map;
    
    // need reference to own player singleton
}

@property (atomic,readonly) ECPlayer* owner;
@property (atomic, retain) KKSpriteNode* unitTouchMask;
@property (nonatomic,assign) bool willReceiveRallyPoints;

-(id) initWithProperties:(NSArray*)properties Owner:(ECPlayer*)player OnMap:(ECMap*)_map;
-(bool) checkIfIntersectsWithNode:(SKNode*)node ByPlayer:(int)gameId;
-(bool) validateRallyPoint:(CGPoint)newRallyPoint;
-(bool) addRallyPoint:(CGPoint)rallyPoint;
-(void) executeRallyPointQueue;

@end
