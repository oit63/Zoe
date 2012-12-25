//
//  Prediction.m
//

#import "Prediction.h"

@implementation Prediction
@synthesize destination, estimate;

- (void)dealloc {
	[destination release];
	[estimate release];
	[super dealloc];
}

@end