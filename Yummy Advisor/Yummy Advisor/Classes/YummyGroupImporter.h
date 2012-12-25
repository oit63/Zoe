#import <libxml/tree.h>

@class YummyGroupImporter, YummyItem, YummyGroup;

// Protocol for the importer to communicate with its delegate.
@protocol YummyGroupImporterDelegate <NSObject>

@optional
// Notification posted by NSManagedObjectContext when saved.
- (void)importerDidSave:(NSNotification *)saveNotification;
// Called by the importer when parsing is finished.
- (void)importerDidFinishParsingData:(YummyGroupImporter *)importer;
// Called by the importer in the case of an error.
- (void)importer:(YummyGroupImporter *)importer didFailWithError:(NSError *)error;
@end


@interface YummyGroupImporter : NSOperation 
{
@private
    id <YummyGroupImporterDelegate> delegate;
    // Reference to the libxml parser context
    xmlParserCtxtPtr context;
    NSURLConnection *rssConnection;
    // Overall state of the importer, used to exit the run loop.
    BOOL done;
    // State variable used to determine whether or not to ignore a given XML element
    BOOL parsingAnItem;
    // The following state variables deal with getting character data from XML elements. This is a potentially expensive 
    // operation. The character data in a given element may be delivered over the course of multiple callbacks, so that
    // data must be appended to a buffer. The optimal way of doing this is to use a C string buffer that grows exponentially.
    // When all the characters have been delivered, an NSString is constructed and the buffer is reset.
    BOOL storingCharacters;
    NSMutableData *characterBuffer;
    // A reference to the current YummyItem the importer is working with.
    YummyItem *currentItem;
    // A reference to the current YummyGroup the importer is working with.
    YummyGroup *currentGroup;
    // The number of parsed songs is tracked so that the autorelease pool for the parsing thread can be periodically
    // emptied to keep the memory footprint under control. 
    NSUInteger countForCurrentBatch;
    NSAutoreleasePool *importPool;
    NSDateFormatter *dateFormatter;
    NSManagedObjectContext *insertionContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSEntityDescription *yummyItemEntityDescription;
    NSEntityDescription *yummyGroupEntityDescription;
    NSURL *requestURL;
    NSMutableArray *groups;
}

@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic, retain) NSURL *requestURL;
@property (nonatomic, assign) id <YummyGroupImporterDelegate> delegate;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *insertionContext;
@property (nonatomic, retain, readonly) NSEntityDescription *yummyItemEntityDescription;
@property (nonatomic, retain, readonly) NSEntityDescription *yummyGroupEntityDescription;

// Although NSURLConnection is inherently asynchronous, the parsing can be quite CPU intensive on the device, so
// the user interface can be kept responsive by moving that work off the main thread. This does create additional
// complexity, as any code which interacts with the UI must then do so in a thread-safe manner.
- (void)main;
@end