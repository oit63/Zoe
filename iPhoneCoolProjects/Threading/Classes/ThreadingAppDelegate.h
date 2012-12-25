

#import <UIKit/UIKit.h>

@class ThreadingViewController;

@interface ThreadingAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ThreadingViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ThreadingViewController *viewController;

@end

