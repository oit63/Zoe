//
//  tableexAppDelegate.m
//  tableex
//
//  Created by Shannon Appelcline on 6/20/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "tableexAppDelegate.h"
#import "RootViewController.h"

@implementation tableexAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	
	[window	addSubview:myTable.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[window release];
	[super dealloc];
}


@end
