//
//  KKSpriteNode+Utilities.h
//  Eggscalibur
//
//  Created by Michael Garrido on 2/5/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface KKSpriteNode (Utilities)
-(CGPoint) positionAtMapX:(int)x andY: (int)y;
-(float) positionXAtMapX:(int)x;
-(float) positionYAtMapY:(int)y;
-(int) mapXatPositionX:(float)x;
-(int) mapYatPositionY:(float)y;
-(float) moveDurationAcrossTiles:(int)tileCount AtSpeed: (float)speed;

-(int) mapXatCurrentPosition;
-(int) mapYAtCurrentPosition;
@end
