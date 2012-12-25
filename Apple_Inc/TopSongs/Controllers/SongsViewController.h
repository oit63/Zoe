/*
     File: SongsViewController.h
 Abstract: Lists all songs in a table view. Also allows sorting and grouping via bottom segmented control.
  Version: 1.3
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>

@class SongDetailsController;

@interface SongsViewController : UIViewController 
{
@private
    SongDetailsController *detailController;
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    UITableView *tableView;
    UISegmentedControl *fetchSectioningControl;
}

@property (nonatomic, retain, readonly) SongDetailsController *detailController;
@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *fetchSectioningControl;

- (IBAction)changeFetchSectioning:(id)sender;

- (void)fetch;

@end
