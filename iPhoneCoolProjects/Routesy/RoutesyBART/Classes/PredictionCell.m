//
//  PredictionCell.m
//

#import "PredictionCell.h"

@implementation PredictionCell
@synthesize destinationLabel;
@synthesize estimateLabel;

- (void)dealloc {
	[destinationLabel release];
	[estimateLabel release];
    [super dealloc];
}


@end
