//
//  SphereNetAppDelegate.m
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright Rogue Amoeba Software, LLC 2009. All rights reserved.
//

#import "SphereNetAppDelegate.h"
#import "SphereNetViewController.h"

@implementation SphereNetAppDelegate

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
