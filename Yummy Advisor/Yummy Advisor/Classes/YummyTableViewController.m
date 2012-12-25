//
//  YummyItemTableViewController.m
//  Yummy.Advisor
//
//  Created by ttron on 4/14/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "YummyTableViewController.h"
#import "YummyGroup.h"
#import "YummyTableCell.h"

@implementation YummyTableViewController
@synthesize tableView,navigationBar;
@synthesize groups;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        //self.groups=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int tablePadding = 40;
	int tableWidth = [tableView frame].size.width;
	if (tableWidth > 480) 
    { // iPad
		tablePadding = 110;
	}
	
	YummyTableCell *cell;
    //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"URLCell"] autorelease];
    cell=[YummyTableCell cell];
    YummyGroup *currentGroup=(YummyGroup*)[self.groups objectAtIndex:[indexPath section]];
    YummyItem *currentItem=[currentGroup itemAtIndex:[indexPath row]];
    NSLog(@"%@",currentItem.title);//XXX
    cell.yummyItem=currentItem;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
	return [(YummyGroup*)[self.groups objectAtIndex:section]numberOfItemsInGroup];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 256;// [YummyTableCell neededHeightForDescription:intro withTableWidth:[tableView frame].size.width]+20;
}

- (NSString *)tableView:(UITableView *)theTableView titleForHeaderInSection:(NSInteger)section
{
	return [(YummyGroup*)[self.groups objectAtIndex:section]groupName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [self.groups count];
}
@end