//
//  ECPlayer.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECPlayer.h"

@implementation ECPlayer

@synthesize userName, userId, deck;

-(id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

-(id) initWithName:(NSString*)_name Id:(int)_id Deck:(NSArray*)_deck
{
    self = [super init];
    
    if (self)
    {
        userName = _name;
        userId = _id;
        deck = [[NSMutableArray alloc] initWithArray:_deck];
        squad = [[NSMutableArray alloc] init];

    }
    
    return self;
}
/*
-(bool) addEnergy:(float)energyAmount ToPlayer:(int)playerId
{
    if (playerId == 1)
    {
        if (playerEnergyLevel>=playerEnergyMax){
            NSLog(@"player energy full");
            return false;
        }
        else
        {
            if (playerEnergyLevel+energyAmount>playerEnergyMax){
                energyAmount = playerEnergyMax-playerEnergyLevel;
            }
            playerEnergyLevel+=energyAmount;
            [self updatePlayerEnergyIndicatorAtSpeed:0.1];
            return true;
        }
    }
    else
        return false;
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

-(void) updatePlayerEnergyIndicatorAtSpeed: (float)speed
{
    playerEnergyCount.text = [NSString stringWithFormat:@"%i",[[NSNumber numberWithFloat:playerEnergyLevel] intValue]];
    
    SKAction *resizeIndicator = [SKAction resizeToWidth:playerEnergyLevelMaxSize*(playerEnergyLevel/playerEnergyMax) duration:speed];
    [playerEnergyLevelIndicator runAction:resizeIndicator];
}


-(void) transferEnergyFromPlayerToUnit:(KKNode*)unit
{
    float unitChargeMultiple = 2.0;
    float unitChargeAmount = 50.0;
    
    if (energyLevel<energyMax){
        if ([self removeEnergy:unitChargeAmount FromPlayer:[[unit.userData valueForKey:@"ownerId"] integerValue]]){
            [self addEnergy:unitChargeAmount*unitChargeMultiple ToUnit:unit];
        }
    }
    if (energyLevel>=movementCost){
        canSetRallyPoints = YES;
    }
}
*/
@end
