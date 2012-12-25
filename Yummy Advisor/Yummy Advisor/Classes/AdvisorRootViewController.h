//
//  FirstLevelViewController.h
//  Yummy Advisor
//
//  Created by ttron on 3/11/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DetailViewController.h"

@interface AdvisorRootViewController : UITableViewController<UISplitViewControllerDelegate>  
{
    //NSArray *advisorableItems;
    UISplitViewController *splitViewController;
    UIPopoverController *popoverController;    
    UIBarButtonItem *rootPopoverButtonItem;
}

@property (nonatomic, assign) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIBarButtonItem *rootPopoverButtonItem;
//@property (nonatomic, retain) NSArray *advisorableItems;
@end
