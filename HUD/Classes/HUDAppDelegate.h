//
//  HUDAppDelegate.h
//  HUD
//
//  Created by Keith A Peters on 4/11/09.
//  Copyright BIT-101 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HUDViewController;

@interface HUDAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    HUDViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HUDViewController *viewController;

@end

