//
//  ECTile.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECTile.h"

@implementation ECTile

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

@end
