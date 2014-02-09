//
//  ECTile.h
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface ECTile : KKSpriteNode
{
    int ownerId;
}

-(id)initWithWidth:(float)width AtX:(int)x andY:(int)y;

@end
