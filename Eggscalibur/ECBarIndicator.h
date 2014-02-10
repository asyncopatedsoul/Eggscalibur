//
//  ECBarIndicator.h
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface ECBarIndicator : KKSpriteNode

-(id) initWithSize:(CGSize)size Color:(UIColor*)color MaxValue:(float)maxValue;
-(void) updateLevelByAmount:(float)amount;
-(void) updateDisplay;

@end
