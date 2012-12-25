//
//  RootViewController.m
//  ParseQuakes
//
//  Created by Bill Dudney on 9/1/09.
//  Copyright Gala Factory 2009. All rights reserved.
//
//  Licensed under the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0.html
//

#import "RootViewController.h"
#import "Earthquake.h"
#import "EarthquakeParser.h"

@implementation RootViewController

@synthesize earthquakes = _earthquakes;

- (void)parser:(EarthquakeParser *)parser addEarthquake:(Earthquake *)earthquake {
  [self.earthquakes addObject:earthquake];
  NSIndexPath *path = [NSIndexPath indexPathForRow:(self.earthquakes.count - 1)
                                         inSection:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path]
                                                 withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)parser:(EarthquakeParser *)parser encounteredError:(NSError *)error {
}

- (void)parserFinished:(EarthquakeParser *)parser {
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _shouldUseLibXML = YES;
  self.earthquakes = [NSMutableArray array];
  EarthquakeParser *parser = [EarthquakeParser earthquakeParser];
  parser.shouldUseLibXML = _shouldUseLibXML;
  parser.delegate = self;
  [parser getEarthquakeData];
  parser = nil;
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"LibXML"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self action:@selector(switchParser)] autorelease];
}

- (void)switchParser {
  _shouldUseLibXML = !_shouldUseLibXML;
  if(_shouldUseLibXML) {
    self.navigationItem.rightBarButtonItem.title = @"LibXML";
  } else {
    self.navigationItem.rightBarButtonItem.title = @"NSXML";
  }
  self.earthquakes = [NSMutableArray array];
  EarthquakeParser *parser = [EarthquakeParser earthquakeParser];
  parser.shouldUseLibXML = _shouldUseLibXML;
  parser.delegate = self;
  [parser getEarthquakeData];
  parser = nil;
  [self.tableView reloadData];
}

- (void)viewDidUnload {
  self.earthquakes = nil;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.earthquakes.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.


	cell.textLabel.text = [[self.earthquakes objectAtIndex:indexPath.row] place];
	cell.detailTextLabel.text = [[[self.earthquakes objectAtIndex:indexPath.row] magnitude] description];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    // Pass the selected object to the new view controller.
    /// ...
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


/*
// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}
*/

- (void)dealloc {
  [super dealloc];
}

@end

