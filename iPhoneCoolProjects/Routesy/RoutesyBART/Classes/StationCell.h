//
//  StationCell.h
//

#import <UIKit/UIKit.h>

@interface StationCell : UITableViewCell {
		
	UILabel *stationNameLabel;
	UILabel *distanceLabel;
	
}

@property (nonatomic,retain) IBOutlet UILabel *stationNameLabel;
@property (nonatomic,retain) IBOutlet UILabel *distanceLabel;

@end
