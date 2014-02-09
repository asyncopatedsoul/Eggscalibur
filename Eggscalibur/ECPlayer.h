//
//  ECPlayer.h
//  Eggscalibur
//
//  Created by Michael Garrido on 2/2/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECPlayer : NSObject
{
    NSMutableArray* squad;
    NSMutableArray* deck;
    NSString* userName;
    int userId;
    int gameId;
}

@property (atomic,readonly) NSString* userName;
@property (atomic,readonly) int userId;
@property (atomic,readonly) int gameId;
@property (atomic,retain) NSMutableArray* deck;

-(id) initWithName:(NSString*)name Id:(int)id Deck:(NSArray*)deck;

-(void) transferEnergyFromPlayerToUnit:(KKNode*)unit;

@end
