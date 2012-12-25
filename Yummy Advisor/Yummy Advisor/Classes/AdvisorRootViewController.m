//
//  FirstLevelViewController.m
//  Yummy Advisor
//
//  Created by ttron on 3/11/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "AdvisorRootViewController.h"
#import "YummySecondLevelViewController.h"
#import "BlankViewController.h"

@implementation AdvisorRootViewController
@synthesize splitViewController;
@synthesize popoverController;
@synthesize rootPopoverButtonItem;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.title=@"Yummy Advisor Items";
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [popoverController release];
    [rootPopoverButtonItem release];
    [splitViewController release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    self.title=@"Advisors";
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(310.0f, self.tableView.rowHeight*5.0f);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch ([indexPath row]) 
    {
		case 0:
			[[cell textLabel] setText:@"HOME"];
			break;
		case 1:
			[[cell textLabel] setText:@"Cash Report"];
			break;
		case 2:
			[[cell textLabel] setText:@"Dish Management"];
			break;
		case 3:
			[[cell textLabel] setText:@"FIFO"];
			break;
		case 4:
			[[cell textLabel] setText:@"SWOT"];
			break;
	}
    cell.imageView.image = [UIImage imageNamed:@"Icon57.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YummySecondLevelViewController *nextController = [[YummySecondLevelViewController alloc]init];
    //NSString *url=@"http://yummy.juston.me:8080/cc.tsst.onme.yummy/rest/groups";
    NSString *url=@"http://192.168.1.57:8080/cc.tsst.onme.yummy/rest/groups";
    [nextController setRequestURLStr:url];
    [url release];
    [nextController setSplitViewController:self.splitViewController];
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark -
#pragma mark Split view support
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc 
{
    [barButtonItem setTitle:@"Advisors"];
	[self setPopoverController:pc];
	[self setRootPopoverButtonItem:barButtonItem];
	//BlankViewController *detailViewController = [[[BlankViewController alloc]initWithNibName:@"BlankView" bundle:nil]autorelease];//[[splitViewController viewControllers] objectAtIndex:1];
    BlankViewController *detailViewController = [[splitViewController viewControllers] objectAtIndex:1];
    [detailViewController showNavigationButton:barButtonItem];
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self setPopoverController:nil];
	[self setRootPopoverButtonItem:nil];
	//BlankViewController *detailViewController = [[[BlankViewController alloc]initWithNibName:@"BlankView" bundle:nil] autorelease];
    BlankViewController *detailViewController = [[splitViewController viewControllers] objectAtIndex:1];
    [detailViewController hideNavigationButton:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc willPresentViewController: (UIViewController *)aViewController
{
    if (pc != nil) 
    {
        [pc dismissPopoverAnimated:YES];
    }
}
@end