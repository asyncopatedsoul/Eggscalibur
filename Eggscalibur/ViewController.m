/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import "ViewController.h"
//#import "MyScene.h"
#import "SoloScene.h"
#import "GameCenterManager.h"


@implementation ViewController

@synthesize gameCenterManager;

-(void) presentFirstScene
{
	NSLog(@"%@", koboldKitCommunityVersion());
	NSLog(@"%@", koboldKitProVersion());
    
    ourRandom = arc4random();
    [self setGameState:kGameStateWaitingForMatch];
    
    // Game Center Manager
    if([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager = [[GameCenterManager alloc] init];
		[self.gameCenterManager setDelegate: self];
		[self.gameCenterManager authenticateLocalUser];
    }
    
	// create and present first scene
	//MyScene* myScene = [MyScene sceneWithSize:self.view.bounds.size];
	//[self.kkView presentScene:myScene];
    
    SoloScene* myScene = [SoloScene sceneWithSize:self.view.bounds.size];
	[self.kkView presentScene:myScene];
}

#pragma mark Matchmaking

- (void)setGameState:(GameState)state {
    
    NSString* gameState;
    
    if (state == kGameStateWaitingForMatch) {
       gameState = @"Waiting for match";
    } else if (state == kGameStateWaitingForRandomNumber) {
        gameState = @"Waiting for rand #";
    } else if (state == kGameStateWaitingForStart) {
        gameState = @"Waiting for start";
    } else if (state == kGameStateActive) {
        gameState = @"Active";
    } else if (state == kGameStateDone) {
        gameState = @"Done";
    }
    
    NSLog(@"GAME STATE: %@",gameState);
}

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [self.gameCenterManager.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        NSLog(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}

#pragma mark GameCenterDelegateProtocol Methods
//Delegate method used by processGameCenterAuth to support looping waiting for game center authorization
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.gameCenterManager authenticateLocalUser];
}

- (void) processGameCenterAuth: (NSError*) error
{
	if(error == NULL)
	{
        NSLog(@"processGameCenterAuth");
		//[self.gameCenterManager reloadHighScoresForCategory: self.currentLeaderBoard];
        [self.gameCenterManager findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:self];
	}
	else
	{
		UIAlertView* alert= [[UIAlertView alloc] initWithTitle: @"Game Center Account Required"
                                                        message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]
                                                       delegate: self cancelButtonTitle: @"Try Again..." otherButtonTitles: NULL];
		[alert show];
	}
	
}

- (void)sendGameBegin {
    NSLog(@"ENTER sendGameBegin");
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
}

- (void)tryStartGame {
    NSLog(@"ENTER tryStartGame");
    //if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
    //}
    
}

#pragma mark GameCenterManagerDelegate

- (void)matchStarted {
    NSLog(@"Match started");
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)matchEnded {
    NSLog(@"Match ended");
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = playerID;
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        NSLog(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            NSLog(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {
            NSLog(@"We are player 1");
            //isPlayer1 = YES;
        } else {
            NSLog(@"We are player 2");
            //isPlayer1 = NO;
        }
        
        if (!tie) {
            receivedRandom = YES;
            //if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            //}
            [self tryStartGame];
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {
        
        [self setGameState:kGameStateActive];
        
    } else if (message->messageType == kMessageTypeMove) {
        
        NSLog(@"Received move");
        
        /*
        if (isPlayer1) {
            [player2 moveForward];
        } else {
            [player1 moveForward];
        }
         */
    } else if (message->messageType == kMessageTypeGameOver) {
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        NSLog(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
            //[self endScene:kEndReasonLose];
        } else {
            //[self endScene:kEndReasonWin];
        }
        
    }    
}

- (void)sendMove {
    
    MessageMove message;
    message.message.messageType = kMessageTypeMove;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];
    [self sendData:data];
    
}

- (void)sendGameOver:(BOOL)player1Won {
    
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];
    [self sendData:data];
    
}

@end
