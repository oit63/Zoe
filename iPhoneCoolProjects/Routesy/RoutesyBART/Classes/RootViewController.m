//
//  RootViewController.m
//

#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>
#import "RootViewController.h"
#import "RoutesyBARTAppDelegate.h"
#import "Station.h"
#import "BARTPredictionLoader.h"

@implementation RootViewController
@synthesize stations;
@synthesize predictionController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Start updating the location so that we can sort the list by the closest
	// stations to the user
	CLLocationManager *locationManager = [RoutesyBARTAppDelegate sharedLocationManager];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
	
	// Load the list of stations from the static database
    self.stations = [NSMutableArray array];
	
	sqlite3 *database;
	sqlite3_stmt *statement;
	
	NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"routesy" ofType:@"db"];
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		char *sql = "SELECT id, name, lat, lon FROM stations";
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// Step through each row in the resultset
            while (sqlite3_step(statement) == SQLITE_ROW) {
				
				const char* station_id = (const char*)sqlite3_column_text(statement, 0);
				const char* station_name = (const char*)sqlite3_column_text(statement, 1);
				double lat = sqlite3_column_double(statement, 2);
				double lon = sqlite3_column_double(statement, 3);
				
				Station *station = [[Station alloc] init];
				station.stationId = [NSString stringWithUTF8String:station_id];
				station.name = [NSString stringWithUTF8String:station_name];
				station.latitude = lat;
				station.longitude = lon;
				
				[self.stations addObject:station];
				[station release];
            }
		}
	}
	
	self.tableView.userInteractionEnabled = NO;
	[[BARTPredictionLoader sharedBARTPredictionLoader] loadPredictionXML:self];
}

- (void)xmlDidFinishLoading {
	self.tableView.userInteractionEnabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[self sortStationsByDistanceFrom:newLocation];
	[self.tableView reloadData];
	[manager stopUpdatingLocation];
}

- (void)sortStationsByDistanceFrom:(CLLocation*)location {
	Station *station;
	CLLocation *stationLocation;
	for (station in self.stations) {
		stationLocation = [[CLLocation alloc] initWithLatitude:station.latitude longitude:station.longitude];
		station.distance = [stationLocation getDistanceFrom:location] / 1609.344;
		[stationLocation release];
	}
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
	[self.stations sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"station";
	Station *station = [self.stations objectAtIndex:indexPath.row];
	
    StationCell *cell = (StationCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewCell];
    }
	
	cell.stationNameLabel.text = station.name;
	if (station.distance) {
		cell.distanceLabel.text = [NSString stringWithFormat:@"%0.1f mi", station.distance];
	} else {
		cell.distanceLabel.text = @"";
	}
	
    return cell;
}

- (StationCell*)createNewCell {
	StationCell *newCell = nil;
	NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"StationCell" owner:self options:nil];
	NSObject *nibItem;
	for (nibItem in nibItems) {
		if ([nibItem isKindOfClass:[StationCell class]]) {
			newCell = (StationCell*)nibItem;
			break;
		}
	}
	return newCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Station *selectedStation = [self.stations objectAtIndex:indexPath.row];
	self.predictionController.station = selectedStation;
	[self.navigationController pushViewController:self.predictionController animated:YES];
}

// When the user taps the blue disclosure detail accessory on a cell, make it act the same as
// if the user selected the entire cell.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)dealloc {
	[stations release];
	[predictionController release];
    [super dealloc];
}


@end

