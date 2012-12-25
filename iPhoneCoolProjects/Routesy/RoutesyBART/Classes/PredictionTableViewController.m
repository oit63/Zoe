//
//  PredictionTableViewController.m
//

#import "PredictionTableViewController.h"
#import "BARTPredictionLoader.h"
#import "Prediction.h"
#import "PredictionCell.h"

@implementation PredictionTableViewController
@synthesize station;
@synthesize predictions;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.title = self.station.name;
	
	self.predictions = [[BARTPredictionLoader sharedBARTPredictionLoader] predictionsForStation:self.station.stationId];
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.predictions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"prediction";
	Prediction *prediction = [self.predictions objectAtIndex:indexPath.row];
	
    PredictionCell *cell = (PredictionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewCell];
    }
	
	cell.destinationLabel.text = prediction.destination;
	cell.estimateLabel.text = prediction.estimate;
	
    return cell;
}

- (PredictionCell*)createNewCell {
	PredictionCell *newCell = nil;
	NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"PredictionCell" owner:self options:nil];
	NSObject *nibItem;
	for (nibItem in nibItems) {
		if ([nibItem isKindOfClass:[PredictionCell class]]) {
			newCell = (PredictionCell*)nibItem;
			break;
		}
	}
	return newCell;
}

- (void)dealloc {
	[station release];
	[predictions release];
    [super dealloc];
}


@end

