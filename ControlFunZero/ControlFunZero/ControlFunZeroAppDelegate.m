//
//  ControlFunZeroAppDelegate.m
//  ControlFunZero
//
//  Created by ttron on 1/19/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "ControlFunZeroAppDelegate.h"
#import "ControlFunZeroViewController.h"

@implementation ControlFunZeroAppDelegate
@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Add the view controller's view to the window and display.
    //[self.window setRootViewController:viewController];
   [self.window addSubview:viewController.view];
   [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc 
{
    [viewController release];
    [window release];
    [super dealloc];
}
@end
