/*
     File: SongsViewController.m
 Abstract: Lists all songs in a table view. Also allows sorting and grouping via bottom segmented control.
  Version: 1.3
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "SongsViewController.h"
#import "SongDetailsController.h"
#import "Song.h"

@implementation SongsViewController

@synthesize managedObjectContext, tableView, fetchSectioningControl;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    self.navigationItem.hidesBackButton = YES;
    [self fetch];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.tableView = nil;
    self.fetchSectioningControl = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    [fetchedResultsController release];
    [managedObjectContext release];
    [detailController release];
    [tableView release];
    [fetchSectioningControl release];
    [super dealloc];
}

- (SongDetailsController *)detailController 
{
    if (detailController == nil) 
    {
        detailController = [[SongDetailsController alloc] initWithNibName:@"SongDetailsView" bundle:nil];
    }
    return detailController;
}

- (void)handleSaveNotification:(NSNotification *)aNotification 
{
    [managedObjectContext mergeChangesFromContextDidSaveNotification:aNotification];
    [self fetch];
}

- (IBAction)changeFetchSectioning:(id)sender 
{
    [fetchedResultsController release];
    fetchedResultsController = nil;
    [self fetch];
}

- (void)fetch 
{
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    NSAssert2(success, @"Unhandled error performing fetch at SongsViewController.m, line %d: %@", __LINE__, [error localizedDescription]);
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController == nil) 
    {
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Song" inManagedObjectContext:managedObjectContext]];
        NSArray *sortDescriptors = nil;
        NSString *sectionNameKeyPath = nil;
        if ([fetchSectioningControl selectedSegmentIndex] == 1) 
        {
            sortDescriptors = [NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"category.name" ascending:YES] autorelease], [[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES] autorelease], nil];
            sectionNameKeyPath = @"category.name";
        } 
        else 
        {
            sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES] autorelease]];
        }
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    }    
    return fetchedResultsController;
}    

#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table 
{
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section 
{ 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    if ([fetchSectioningControl selectedSegmentIndex] == 0) 
    {
        return [NSString stringWithFormat:NSLocalizedString(@"Top %d songs", @"Top %d songs"), [sectionInfo numberOfObjects]];
    }
    else 
    {
        return [NSString stringWithFormat:NSLocalizedString(@"%@ - %d songs", @"%@ - %d songs"), [sectionInfo name], [sectionInfo numberOfObjects]];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table 
{
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    return [fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    // tell table which section corresponds to section title/index (e.g. "B",1))
    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *kCellIdentifier = @"SongCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    Song *song = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"#%d %@", @"#%d %@"), [song.rank integerValue], song.title];
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    self.detailController.song = [fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:self.detailController animated:YES];
}

@end