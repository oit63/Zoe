#import <UIKit/UIKit.h>

#import "cocos2d.h"
#import "chipmunk.h"

@class MinigolfViewController;

@interface MinigolfAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	MinigolfViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@end

