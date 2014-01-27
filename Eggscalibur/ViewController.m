/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import "ViewController.h"
//#import "MyScene.h"
#import "SoloScene.h"

@implementation ViewController

-(void) presentFirstScene
{
	NSLog(@"%@", koboldKitCommunityVersion());
	NSLog(@"%@", koboldKitProVersion());

	// create and present first scene
	//MyScene* myScene = [MyScene sceneWithSize:self.view.bounds.size];
	//[self.kkView presentScene:myScene];
    
    SoloScene* myScene = [SoloScene sceneWithSize:self.view.bounds.size];
	[self.kkView presentScene:myScene];
}

@end
