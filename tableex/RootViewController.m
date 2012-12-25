//
//  RootViewController.m
//  tableex
//
//  Created by Shannon Appelcline on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "CoreGraphics/CGGeometry.h"

@implementation RootViewController
@synthesize masterColorList;

- (id)initWithCoder:(NSCoder *)decoder 
{
	
	if (self = [super initWithCoder:decoder]) 
    {	

	  NSArray *colorList = [NSArray arrayWithObjects:
						  [NSDictionary dictionaryWithObjectsAndKeys:
						   @"brownColor",@"titleValue",	
						   [UIColor brownColor],@"colorValue",nil],
						  [NSDictionary dictionaryWithObjectsAndKeys:
						   @"orangeColor",@"titleValue",
						   [UIColor orangeColor],@"colorValue",nil],
						  [NSDictionary dictionaryWithObjectsAndKeys:
						   @"purpleColor",@"titleValue",
						   [UIColor purpleColor],@"colorValue",nil],
						  [NSDictionary dictionaryWithObjectsAndKeys:
						   @"redColor",@"titleValue",
						   [UIColor redColor],@"colorValue",nil],
						  nil];
	
	  NSArray *otherColorList = [NSArray arrayWithObjects:
							   [NSDictionary dictionaryWithObjectsAndKeys:
								@"RGB:0.25/0/0",@"titleValue",
								[UIColor colorWithRed:.25 green:0 blue:0 alpha:1],@"colorValue",nil],
							   [NSDictionary dictionaryWithObjectsAndKeys:
								@"RGB:0.5/0/0",@"titleValue",
								[UIColor colorWithRed:.5 green:0 blue:0 alpha:1],@"colorValue",nil],
							   [NSDictionary dictionaryWithObjectsAndKeys:
								@"RGB:0.75/0/0",@"titleValue",
								[UIColor colorWithRed:.75 green:0 blue:0 alpha:1],@"colorValue",nil],
							   nil];
	
	  masterColorList = [NSArray arrayWithObjects:colorList,otherColorList,nil];
	
	  [masterColorList retain];//@_@
	}
	
	return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
		
	return masterColorList.count;

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	
	return [[masterColorList objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
    {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}

	cell.textColor= [[[masterColorList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"colorValue"];
	cell.selectedTextColor = [[[masterColorList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"colorValue"];
    cell.text = [[[masterColorList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"titleValue"];

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	
	if (section == 0) 
    {
		return @"SDK Colors";
	} 
    else if (section == 1) 
    {
		return @"RGB Colors";
	}
	return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{

	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];

}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
	}
}
*/
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/
/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/
/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


- (void)dealloc {
	[super dealloc];
	[masterColorList release];//@_@
}


- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


@end

