//
//  YummySecondLevelViewController.m
//  Yummy.Advisor
//
//  Created by ttron on 3/15/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "AdvisorAppDelegatePad.h"
#import "YummySecondLevelViewController.h"
#import "YummyGroupImporter.h"
#import "YummyGroup.h"
#import "YummyItem.h"
#import "YummyTableViewController.h"

@interface YummySecondLevelViewController ()
@end


@implementation YummySecondLevelViewController
@synthesize requestURLStr,groups;
@synthesize splitViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [groups release];
    [requestURLStr release];
    [super dealloc];
}
- (void)viewDidLoad
{
    NSLog(@"%@",self.requestURLStr);
    self.groups=[[NSMutableArray alloc]init];
    YummyGroupImporter *importer = [[[YummyGroupImporter alloc] init] autorelease];
    importer.delegate = self;//@_@
    importer.requestURL = [NSURL URLWithString:self.requestURLStr];
    NSOperationQueue *queue=((AdvisorAppDelegatePad*)[[UIApplication sharedApplication] delegate]).operationQueue;
    [queue addOperation:importer];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}




-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    return ((AdvisorAppDelegatePad*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext 
{
    if (managedObjectContext == nil) 
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    } 
    return managedObjectContext;
}





#pragma mark - YummyGroupImporterDelegate
- (void)importerDidSave:(NSNotification *)saveNotification
{
    NSLog(@"importerDidSave");
    
    if ([NSThread isMainThread]) 
    {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
    }
    else 
    {
         NSLog(@"not inside MainThead perform [importerDidSave] to MainThread.");
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

- (void)importerDidFinishParsingData:(YummyGroupImporter *)importer
{
    NSLog(@"importerDidFinishParsingData");
    [self.groups addObjectsFromArray:importer.groups];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)importer:(YummyGroupImporter *)importer didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError:%@",[error localizedDescription]);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [groups count];
	// ff there's no data yet, return enough rows to fill the screen
    if (count == 0)
	{
        return 1;
    }
    return count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.groups count];
	
	if (indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
            cell.imageView.image = [UIImage imageNamed:@"Icon57.png"];
			//cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (nodeCount == 0 )
        {
            cell.textLabel.text = @"Loading…";
        }
        else 
        {
            cell.textLabel.text = @"All";
        }
		return cell;
    }
    else
    {	
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier] autorelease];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.imageView.image = [UIImage imageNamed:@"Icon57.png"];
        }
        
        YummyGroup *group=((YummyGroup*)[self.groups objectAtIndex:indexPath.row-1]);
        cell.textLabel.text = group.groupName;
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (YummyGroup* group in groups)
    {
        NSArray *items=group.yummyItems;
        NSLog(@"Group with sid:%d",[group.sid integerValue]);
        
        for(YummyItem *item in items)
        {
            NSLog(@"Item with src:%@",item.imageURLString);
        }
    }

    
    // Navigation logic may go here. Create and push another view controller.
    YummyTableViewController *detailViewController = [[YummyTableViewController alloc] initWithNibName:@"YummyTableView" bundle:nil];
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController setGroups:self.groups];
    [self.splitViewController setViewControllers:[NSArray arrayWithObjects:[self navigationController],detailViewController,nil]];
    [detailViewController release];
}
@end