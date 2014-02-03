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
    
    float movementSpeed;
    float movementCost;
    
    float energyRechargeSpeed;
    float energyRechargeAmount;
    
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

@end