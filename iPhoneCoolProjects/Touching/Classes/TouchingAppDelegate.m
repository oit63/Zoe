//
//  TouchingAppDelegate.m
//  Touching
//
//  Created by Canis Lupus
//  Copyright Wooji Juice 2009. All rights reserved.
//

#import "TouchingAppDelegate.h"

@implementation TouchingAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{        
    [window makeKeyAndVisible];
}


- (void)dealloc 
{
    [window release];
    [super dealloc];
}


@end
