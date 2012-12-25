//
//  AppDelegate.h
//  Yummy Advisor
//
//  Created by ttron on 3/10/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdvisorRootViewController;

@interface AdvisorAppDelegatePad : UIResponder <UIApplicationDelegate>
{
     NSOperationQueue *operationQueue;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
//@property (nonatomic, retain) IBOutlet AdvisorRootViewController *rootViewController;

@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end