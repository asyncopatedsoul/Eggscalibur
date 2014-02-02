//
//  EHMechUnit.h
//  Eggscalibur
//
//  Created by Michael Garrido on 1/28/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface EHMechUnit : KKSpriteNode
{
    // unit properties
    NSMutableArray* rallyPointQueue;
    float movementSpeed;
    float movementCost;
    float energyLevel;
    float energyMax;
    float energyRechargeSpeed;
    float energyRechargeAmount;
    float indicatorBarWidth;
    KKSpriteNode* energyIndicator;
}

@end
