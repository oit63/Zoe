//
//  Station.m
//

#import "Station.h"

@implementation Station
@synthesize stationId, name, latitude, longitude, distance;

- (void)dealloc {
	[stationId release];
	[name release];
	[super dealloc];
}

@end
