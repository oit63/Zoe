//
//  FallingBallsRemakeAppDelegate.m
//  FallingBallsRemake
//
//  Created by Keith A Peters on 4/5/09.
//  Copyright BIT-101 2009. All rights reserved.
//

#import "FallingBallsRemakeAppDelegate.h"
#import "FallingBallsRemakeViewController.h"

@implementation FallingBallsRemakeAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
