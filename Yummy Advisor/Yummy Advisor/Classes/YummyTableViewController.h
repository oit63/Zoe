//
//  YummyItemTableViewController.h
//  Yummy.Advisor
//
//  Created by ttron on 4/14/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "BlankViewController.h"

@interface YummyTableViewController: UIViewController <UITableViewDelegate> 
{
	UINavigationBar *navigationBar;
	UITableView *tableView;
    NSMutableArray *groups;
}

@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *groups;
@end

