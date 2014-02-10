//
//  ECBarIndicator.m
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "ECBarIndicator.h"

@implementation ECBarIndicator
{
    KKLabelNode* levelLabel;
    float level;
    float maxLevel;
}

-(id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

-(id) initWithSize:(CGSize)size Color:(UIColor*)color MaxValue:(float)maxValue
{
    self = [super init];
    
    if (self)
    {
        maxLevel = maxValue;
        level = maxValue;
        
        levelLabel = [KKLabelNode node];
        [self addChild:levelLabel];
        
        [self updateDisplay];
    }
    
    return self;
}

-(void) updateLevelByAmount:(float)amount
{
    level+=amount;
    [self updateDisplay];
}

-(void) updateDisplay
{
    levelLabel.text = [NSString stringWithFormat:@"%i",(int)level];
}

@end
