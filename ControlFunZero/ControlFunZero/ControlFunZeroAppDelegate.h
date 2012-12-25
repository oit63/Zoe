//
//  ControlFunZeroAppDelegate.h
//  ControlFunZero
//
//  Created by ttron on 1/19/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ControlFunZeroViewController;

@interface ControlFunZeroAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    ControlFunZeroViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ControlFunZeroViewController *viewController;
@end
