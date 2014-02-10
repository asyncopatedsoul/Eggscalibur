//
//  ECPlayerHUD.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECPlayerHUD.h"
#import "ECMechUnit.h"

@implementation ECPlayerHUD
{
    float widthSideDock;
    float heightSideDock;
    
    KKSpriteNode* background;
    
    ECMechUnit* selectedUnit;
}

-(id) init{
    self = [super init];
    
    widthSideDock = 80.0;
    heightSideDock = 320.0;
    
    if (self)
    {
        background = [KKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(widthSideDock, heightSideDock)];
        background.position = CGPointMake(widthSideDock/2, heightSideDock/2);
        [self addChild:background];
    }
    
    return self;
}

-(void) setSelectedUnit:(ECMechUnit*)unit
{
    selectedUnit = unit;
    
    // load and link unit properties and ablitities 
}

-(void) setupPVPHUD
{
    /*
     KKNode* playerHUDRoot;
     KKSpriteNode* playerEnergyLevelIndicator;
     float playerEnergyLevelMaxSize;
     float playerEnergyMax;
     float playerEnergyLevel;
     */
    /*
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
     */
}

@end
