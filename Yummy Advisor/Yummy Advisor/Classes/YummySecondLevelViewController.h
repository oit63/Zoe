//
//  YummySecondLevelViewController.h
//  Yummy.Advisor
//
//  Created by ttron on 3/15/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YummyGroupImporter.h"

@interface YummySecondLevelViewController : UITableViewController<YummyGroupImporterDelegate>
{
    NSString *requestURLStr;
    NSMutableArray *groups;
    NSManagedObjectContext *managedObjectContext;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
}

@property (nonatomic,retain) UISplitViewController *splitViewController;
@property (nonatomic,retain) NSString *requestURLStr;
@property (nonatomic,retain) NSMutableArray *groups;
@property (nonatomic,retain,readonly) NSManagedObjectContext *managedObjectContext;
@end