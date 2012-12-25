#import <UIKit/UIKit.h>
#import "iTunesRSSImporter.h"

@class iTunesRSSImporter, SongsViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, iTunesRSSImporterDelegate> 
{
    UIWindow *window;
    UINavigationController *navigationController;
    SongsViewController *songsViewController;
    
    iTunesRSSImporter *importer;
    NSOperationQueue *operationQueue;
    
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString *persistentStorePath;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet SongsViewController *songsViewController;

// Properties for the importer and its background processing queue.
@property (nonatomic, retain) iTunesRSSImporter *importer;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

// Properties for the Core Data stack.
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSString *persistentStorePath;
@end