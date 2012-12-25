//
//  RoutesyBARTAppDelegate.m
//

#import <CoreLocation/CoreLocation.h>
#import "RoutesyBARTAppDelegate.h"
#import "RootViewController.h"

@implementation RoutesyBARTAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

+ (CLLocationManager*)sharedLocationManager {
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
			_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		}
	}
	return _locationManager;
}

@end
