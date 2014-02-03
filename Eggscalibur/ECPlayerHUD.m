//
//  ECPlayerHUD.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECPlayerHUD.h"

@implementation ECPlayerHUD

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

@end
