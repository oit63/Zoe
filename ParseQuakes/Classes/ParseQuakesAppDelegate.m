//
//  ParseQuakesAppDelegate.m
//  ParseQuakes
//
//  Created by Bill Dudney on 9/1/09.
//  Copyright Gala Factory 2009. All rights reserved.
//
//  Licensed under the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0.html
//

#import "ParseQuakesAppDelegate.h"
#import "RootViewController.h"


@implementation ParseQuakesAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after app launch    

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

