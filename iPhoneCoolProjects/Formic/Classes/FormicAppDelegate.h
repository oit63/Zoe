//
//  FormicAppDelegate.h
//  Formic
//
//  Created by Wolfgang Ante on 1/8/09.
//  Copyright ARTIS Software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormicViewController;
@class FormicGame;

#define AppDelegate	(FormicAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface FormicAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow				*window;
	FormicViewController	*viewController;
	FormicGame				*game;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FormicViewController *viewController;
@property (readonly) FormicGame *game;

@end
