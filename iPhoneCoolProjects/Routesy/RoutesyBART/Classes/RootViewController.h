//
//  RootViewController.h
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PredictionTableViewController.h"
#import "BARTPredictionLoader.h"
#import "StationCell.h"

@interface RootViewController : UITableViewController <BARTPredictionLoaderDelegate,CLLocationManagerDelegate> {
	
	NSMutableArray *stations;
	PredictionTableViewController *predictionController;
	
}

- (void)sortStationsByDistanceFrom:(CLLocation*)location;
- (StationCell*)createNewCell;

@property (nonatomic,retain) NSMutableArray *stations;
@property (nonatomic,retain) IBOutlet PredictionTableViewController *predictionController;

@end
