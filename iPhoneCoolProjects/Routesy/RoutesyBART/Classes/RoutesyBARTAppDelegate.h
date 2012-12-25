//
//  RoutesyBARTAppDelegate.h
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RoutesyBARTAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

+ (CLLocationManager*)sharedLocationManager;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

