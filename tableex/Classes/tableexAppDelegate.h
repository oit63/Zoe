//
//  tableexAppDelegate.h
//  tableex
//
//  Created by Shannon Appelcline on 6/20/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class tableexViewController;

@interface tableexAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITableViewController *myTable;
}

@property (nonatomic, retain) UIWindow *window;

@end

