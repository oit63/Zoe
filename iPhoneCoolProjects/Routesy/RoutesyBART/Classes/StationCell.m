//
//  StationCell.m
//

#import "StationCell.h"

@implementation StationCell
@synthesize stationNameLabel, distanceLabel;

- (void)dealloc {
	[stationNameLabel release];
	[distanceLabel release];
    [super dealloc];
}

@end
