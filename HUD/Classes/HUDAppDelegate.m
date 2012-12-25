//
//  HUDAppDelegate.m
//  HUD
//
//  Created by Keith A Peters on 4/11/09.
//  Copyright BIT-101 2009. All rights reserved.
//

#import "HUDAppDelegate.h"
#import "HUDViewController.h"

@implementation HUDAppDelegate

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
