//
//  webimageAppDelegate.m
//  webimage
//
//  Created by Shannon Appelcline on 7/7/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "webimageAppDelegate.h"

@implementation webimageAppDelegate

@synthesize window;
@synthesize myWebView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://quote-web.aol.com/?syms=AAPL&e=NAS&action=hq&dur=1&type=mountain&hgl=1&vgl=1&vol=1&splits=1&div=0&w=280&h=391&gran=d"]]];
	
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[window release];
	[myWebView release];
	[super dealloc];
}


@end
