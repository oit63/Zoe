//
//  FallingBallsRemakeAppDelegate.h
//  FallingBallsRemake
//
//  Created by Keith A Peters on 4/5/09.
//  Copyright BIT-101 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FallingBallsRemakeViewController;

@interface FallingBallsRemakeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FallingBallsRemakeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FallingBallsRemakeViewController *viewController;

@end

