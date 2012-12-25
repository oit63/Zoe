//
//  ParseQuakesAppDelegate.h
//  ParseQuakes
//
//  Created by Bill Dudney on 9/1/09.
//  Copyright Gala Factory 2009. All rights reserved.
//
//  Licensed under the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0.html
//

@interface ParseQuakesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

