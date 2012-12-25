//
//  PredictionCell.h
//

#import <UIKit/UIKit.h>

@interface PredictionCell : UITableViewCell {
	UILabel *destinationLabel;
	UILabel *estimateLabel;
}

@property (nonatomic,retain) IBOutlet UILabel *destinationLabel;
@property (nonatomic,retain) IBOutlet UILabel *estimateLabel;

@end
