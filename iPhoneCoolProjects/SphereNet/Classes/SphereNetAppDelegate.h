//
//  SphereNetAppDelegate.h
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright Rogue Amoeba Software, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SphereNetViewController;

@interface SphereNetAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SphereNetViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SphereNetViewController *viewController;

@end

