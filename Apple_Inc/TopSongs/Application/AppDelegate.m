/*
     File: AppDelegate.m
 Abstract: Configures the Core Data persistence stack and starts the RSS importer.
  Version: 1.3
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AppDelegate.h"
#import "SongsViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize songsViewController;

@synthesize importer;

// String used to identify the update object in the user defaults storage.
static NSString * const kLastStoreUpdateKey = @"LastStoreUpdate";

// Get the RSS feed for the first time or if the store is older than kRefreshTimeInterval seconds.
static NSTimeInterval const kRefreshTimeInterval = 3600;

// The number of songs to be retrieved from the RSS feed.
static NSUInteger const kImportSize = 300;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    // check the last update, stored in NSUserDefaults
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastStoreUpdateKey];
    if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > kRefreshTimeInterval) 
    {
        // remove the old store; easier than deleting every object
        // first, test for an existing store
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.persistentStorePath]) 
        {
            NSError *error = nil;
            BOOL oldStoreRemovalSuccess = [[NSFileManager defaultManager] removeItemAtPath:self.persistentStorePath error:&error];
            NSAssert3(oldStoreRemovalSuccess, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
        }
        
        // create an importer object to retrieve, parse, and import into the CoreData store 
        self.importer = [[[iTunesRSSImporter alloc] init] autorelease];
        importer.delegate = self;//@_@
        
        // pass the coordinator so the importer can create its own managed object context
        importer.persistentStoreCoordinator = self.persistentStoreCoordinator;
        importer.iTunesURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/newreleases/limit=%d/rss.xml", kImportSize]];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        // add the importer to an operation queue for background processing (works on a separate thread)
        [self.operationQueue addOperation:importer];
    }

    songsViewController.managedObjectContext = self.managedObjectContext;
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
}

- (NSOperationQueue *)operationQueue 
{
    if (operationQueue == nil) 
    {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}

#pragma mark Core Data stack setup

//
// These methods are very slightly modified from what is provided by the Xcode template
// An overview of what these methods do can be found in the section "The Core Data Stack" 
// in the following article: 
// http://developer.apple.com/iphone/library/documentation/DataManagement/Conceptual/iPhoneCoreData01/Articles/01_StartingOut.html
//

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (persistentStoreCoordinator == nil) 
    {
        NSURL *storeUrl = [NSURL fileURLWithPath:self.persistentStorePath];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        NSError *error = nil;
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
        NSAssert3(persistentStore != nil, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    return persistentStoreCoordinator;
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

- (NSString *)persistentStorePath 
{
    if (persistentStorePath == nil) 
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths lastObject];
        persistentStorePath = [[documentsDirectory stringByAppendingPathComponent:@"TopSongs.sqlite"] retain];
    }
    return persistentStorePath;
}

#pragma mark <iTunesRSSImporterDelegate> Implementation

// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)importerDidSave:(NSNotification *)saveNotification 
{
    if ([NSThread isMainThread]) 
    {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
        [songsViewController fetch];
    }
    else 
    {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

// Helper method for main-thread processing of import completion.
- (void)handleImportCompletion 
{
    // Store the current time as the time of the last import. This will be used to determine whether an
    // import is necessary when the application runs.
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastStoreUpdateKey];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.importer = nil;
}

// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)importerDidFinishParsingData:(iTunesRSSImporter *)importer 
{
    [self performSelectorOnMainThread:@selector(handleImportCompletion) withObject:nil waitUntilDone:NO];
}

// Helper method for main-thread processing of errors received in the delegate callback below.
- (void)handleImportError:(NSError *)error 
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.importer = nil;
    // handle errors as appropriate to your application...
    NSAssert3(NO, @"Unhandled error in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
}

// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)importer:(iTunesRSSImporter *)importer didFailWithError:(NSError *)error 
{
    [self performSelectorOnMainThread:@selector(handleImportError:) withObject:error waitUntilDone:NO];
}

- (void)dealloc 
{
    [operationQueue release];
    [importer release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [persistentStorePath release];
    [songsViewController release];
    [navigationController release];
    [window release];
    [super dealloc];
}

@end

