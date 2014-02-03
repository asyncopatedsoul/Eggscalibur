//
//  ECMap.h
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface ECMap : KKSpriteNode
{
    float tileWidth;
    int mapWidth;

    KKSpriteNode* mapBackground;
    NSMutableArray* mapTiles;
}

@end
