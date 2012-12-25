//
//  PredictionTableViewController.h
//

#import <UIKit/UIKit.h>
#import "Station.h"
#import "PredictionCell.h"

@interface PredictionTableViewController : UITableViewController {
	Station *station;
	NSArray *predictions;
}

- (PredictionCell*)createNewCell;

@property (nonatomic,retain) Station *station;
@property (nonatomic,retain) NSArray *predictions;

@end
