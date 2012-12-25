#import "MinigolfAppDelegate.h"
#import "GameLayer.h"

@implementation MinigolfAppDelegate

@synthesize window;


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	Scene *scene = [Scene node];
	[scene add: [GameLayer node] z:0];
	[[Director sharedDirector] runScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}


@end
