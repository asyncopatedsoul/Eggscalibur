//
//  ECMap.h
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@class ECMechUnit, ECTile;

@interface ECMap : KKSpriteNode
{
    float tileWidth;
    int mapWidth;

    KKSpriteNode* mapBackground;
    NSMutableArray* mapTiles;
    
    NSMutableArray* units;
}

@property (atomic,readonly) NSMutableArray* units;

-(void) addObject:(KKNode*)node ToMapAtX:(int)x andY: (int)y;
-(void) addUnit:(ECMechUnit*)unit ToMapAtX:(int)x andY: (int)y;
-(ECTile*) getTileAtLocation:(CGPoint)point;

@end
