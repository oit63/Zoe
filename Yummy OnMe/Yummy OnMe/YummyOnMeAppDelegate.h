//
//  AppDelegate.h
//  Yummy
//
//  Created by ttron on 1/16/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class YummyMetroViewController;
@interface YummyOnMeAppDelegate :NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    YummyMetroViewController *viewController;
    //NSManagedObjectModel *managedObjectModel_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet YummyMetroViewController *viewController;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end