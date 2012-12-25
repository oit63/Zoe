#import "YummyGroupImporter.h"
#import "YummyGroup.h"
#import "YummyItem.h"
#import "YummyRepo.h"
#import "AdvisorAppDelegatePad.h"
#import <libxml/tree.h>

// Function prototypes for SAX callbacks. This sample implements a minimal subset of SAX callbacks.
// Depending on your application's needs, you might want to implement more callbacks.
static void startElementSAX(void *context, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void endElementSAX(void *context, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void charactersFoundSAX(void *context, const xmlChar *characters, int length);
static void errorEncounteredSAX(void *context, const char *errorMessage, ...);

// Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;

// Class extension for private properties and methods.
@interface YummyGroupImporter ()

@property BOOL storingCharacters;
@property (nonatomic, retain) NSMutableData *characterBuffer;
@property BOOL done;
@property BOOL parsingAnItem;
@property NSUInteger countForCurrentBatch;
@property (nonatomic, retain) YummyItem *currentItem;
@property (nonatomic, retain) YummyGroup *currentGroup;
@property (nonatomic, retain) NSURLConnection *rssConnection;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
// The autorelease pool property is assign because autorelease pools cannot be retained.
@property (nonatomic, assign) NSAutoreleasePool *importPool;

@end

static double lookuptime = 0;

@implementation YummyGroupImporter

@synthesize requestURL, delegate, persistentStoreCoordinator;
@synthesize rssConnection, done, parsingAnItem, storingCharacters, currentItem, countForCurrentBatch, characterBuffer, dateFormatter, importPool;
@synthesize groups,currentGroup;


- (void)dealloc 
{
    [groups release];
    [requestURL release];
    [characterBuffer release];
    [currentItem release];
    [rssConnection release];
    [dateFormatter release];
    [persistentStoreCoordinator release];
    [insertionContext release];
    [yummyItemEntityDescription release];
    [yummyGroupEntityDescription release];
    [super dealloc];
}

- (void)main 
{
    self.groups=[[NSMutableArray alloc]init];
    self.importPool = [[NSAutoreleasePool alloc] init];
    if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) 
    {
        [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    }
    
    done = NO;
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    // necessary because iTunes RSS feed is not localized, so if the device region has been set to other than US
    // the date formatter must be set to US locale in order to parse the dates
    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
    self.characterBuffer = [NSMutableData data];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:requestURL];
    // create the connection with the request and start loading the data
    rssConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    // This creates a context for "push" parsing in which chunks of data that are not "well balanced" can be passed
    // to the context for streaming parsing. The handler structure defined above will be used for all the parsing. 
    // The second argument, self, will be passed as user data to each of the SAX handlers. The last three arguments
    // are left blank to avoid creating a tree in memory.
    context = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
    
    if (rssConnection != nil) 
    {
        do 
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }while (!done);
    }
    
    // Display the total time spent finding a specific object for a relationship
    NSLog(@"lookup time %f", lookuptime);
    // Release resources used only in this thread.
    xmlFreeParserCtxt(context);
    self.characterBuffer = nil;
    self.dateFormatter = nil;
    self.rssConnection = nil;
    self.currentItem = nil;
    NSError *saveError = nil;
    NSAssert1([insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
    
    if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) 
    {
        [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(importerDidFinishParsingData:)]) 
    {
        [self.delegate importerDidFinishParsingData:self];
    }
    
    [importPool release];
    self.importPool = nil;
}

-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    return ((AdvisorAppDelegatePad*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator;
}


- (NSManagedObjectContext *)insertionContext 
{
    if (insertionContext == nil) 
    {
        insertionContext = [[NSManagedObjectContext alloc] init];
        [insertionContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return insertionContext;
}

- (void)forwardError:(NSError *)error 
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(importer:didFailWithError:)]) 
    {
        [self.delegate importer:self didFailWithError:error];
    }
}

- (NSEntityDescription *)yummyItemEntityDescription 
{
    if (yummyItemEntityDescription == nil) 
    {
        yummyItemEntityDescription = [[NSEntityDescription entityForName:@"YummyItem" inManagedObjectContext:self.insertionContext] retain];
    }
    return yummyItemEntityDescription;
}


- (NSEntityDescription *)yummyGroupEntityDescription 
{
    if (yummyGroupEntityDescription == nil) 
    {
        yummyGroupEntityDescription = [[NSEntityDescription entityForName:@"YummyGroup" inManagedObjectContext:self.insertionContext] retain];
    }
    return yummyGroupEntityDescription;
}


- (YummyItem *) currentItem 
{
    if (currentItem == nil) 
    {
        currentItem = [[YummyItem alloc] initWithEntity:self.yummyItemEntityDescription insertIntoManagedObjectContext:self.insertionContext];
        //currentSong.rank = [NSNumber numberWithUnsignedInteger:++rankOfCurrentSong];
    }
    return currentItem;
}

- (YummyGroup *) currentGroup 
{
    if (currentGroup == nil) 
    {
        currentGroup = [[YummyGroup alloc]initWithEntity:self.yummyGroupEntityDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return currentGroup;
}

#pragma mark NSURLConnection Delegate methods

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    [self performSelectorOnMainThread:@selector(forwardError:) withObject:error waitUntilDone:NO];
    // Set the condition which ends the run loop.
    done = YES;
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    // Process the downloaded chunk of data.
    xmlParseChunk(context, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    // Signal the context that parsing is complete by passing "1" as the last parameter.
    xmlParseChunk(context, NULL, 0, 1);
    context = NULL;
    // Set the condition which ends the run loop.
    done = YES; 
}

#pragma mark Parsing support methods

static const NSUInteger kImportBatchSize = 20;

- (void)finishedCurrentItem 
{
   // NSLog(@"finishedCurrentItem uid:%@",self.currentItem.uid);//XXX

    parsingAnItem = NO;
    self.currentItem = nil;
    countForCurrentBatch++;
        
    if (countForCurrentBatch == kImportBatchSize) 
    {
        NSLog(@"save");
        NSError *saveError = nil;
        NSAssert1([self.insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
        countForCurrentBatch = 0;
    }
}

/*
 Character data is appended to a buffer until the current element ends.
 */
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length 
{
    [self.characterBuffer appendBytes:charactersFound length:length];
}

- (NSString *)currentString 
{
    // Create a string with the character data using UTF-8 encoding. UTF-8 is the default XML data encoding.
    NSString *currentString = [[NSString alloc] initWithData:self.characterBuffer encoding:NSUTF8StringEncoding];
    [characterBuffer setLength:0];
    return currentString;
}

@end

#pragma mark SAX Parsing Callbacks

// The following constants are the XML element names and their string lengths for parsing comparison.
// The lengths include the null terminator, to ensure exact matches.
static const char *kName_Item = "item";
static const NSUInteger kLength_Item = 5;
static const char *kName_Title = "title";
static const NSUInteger kLength_Title = 6;
static const char *kName_Group = "group";
static const NSUInteger kLength_Group = 6;
static const char *kName_uid = "uid";
static const NSUInteger kLength_uid = 4;
static const char *kName_sid = "sid";
static const NSUInteger kLength_sid = 4;
static const char *kName_Type = "tp";
static const NSUInteger kLength_Type = 3;
static const char *kName_Name = "name";
static const NSUInteger kLength_Name = 4;
static const char *kName_BgColor = "bgcolor";
static const NSUInteger kLength_BgColor = 8;
static const char *kName_Image = "image";
static const NSUInteger kLength_Image = 6;
static const char *kName_src = "src";
static const NSUInteger kLength_src = 4;



/*
 This callback is invoked when the importer finds the beginning of a node in the XML. For this application,
 out parsing needs are relatively modest - we need only match the node name. An "item" node is a record of
 data about a song. In that case we create a new Song object. The other nodes of interest are several of the
 child nodes of the Song currently being parsed. For those nodes we want to accumulate the character data
 in a buffer. Some of the child nodes use a namespace prefix. 
 */
static void startElementSAX(void *parsingContext, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, 
                            int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes) 
{
    YummyGroupImporter *importer = (YummyGroupImporter *)parsingContext;
    // The second parameter to strncmp is the name of the element, which we known from the XML schema of the feed.
    // The third parameter to strncmp is the number of characters in the element name, plus 1 for the null terminator.
    if (prefix == NULL && !strncmp((const char *)localname, kName_Group, kLength_Group)) 
    {
        const char *key;
        NSString *val;  
        for (int i=0; i<nb_attributes; i++)
        {  
            key =(const char*)attributes[0] ;  
            val = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) 
                                         encoding:NSUTF8StringEncoding];  
            NSLog(@"key=%@,val=%@",[NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding],val);  
            if (!strncmp((const char *)key, kName_sid, kLength_sid)) 
            {  
                importer.currentGroup.sid=[NSNumber numberWithUnsignedInteger:[val integerValue]];  
            }
            else if(!strncmp((const char *)key, kName_BgColor, kLength_BgColor)) 
            {
                importer.currentGroup.bgColorString=val;
            }
            else if(!strncmp((const char *)key, kName_Name, kLength_Name)) 
            {
                importer.currentGroup.groupName=val;
            }
            [val release];  
            attributes += 5;//指针移动5个字符串，到下一个属性  
        }  
    }
    else if (prefix == NULL && !strncmp((const char *)localname, kName_Item, kLength_Item)) 
    {
        importer.parsingAnItem = YES;
        const char *key;
        NSString *val;  
        for (int i=0; i<nb_attributes; i++)
        {  
            key =(const char*)attributes[0] ;  
            val = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) 
                                         encoding:NSUTF8StringEncoding];  
            //NSLog(@"key=%@,val=%@",[NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding],val);  
            if (!strncmp((const char *)key, kName_uid, kLength_uid)) 
            {  
                importer.currentItem.uid=val;  
            }
            else if(!strncmp((const char *)key, kName_Type, kLength_Type)) 
            {
                [importer.currentItem setTypeString:val];            
            }
            [val release];  
            attributes += 5;//指针移动5个字符串，到下一个属性  
        }  
    }
    else if (importer.parsingAnItem )
    {
        if( prefix == NULL && (!strncmp((const char *)localname, kName_Title, kLength_Title)))
            //|| !strncmp((const char *)localname, kName_Category, kLength_Category))) || ((prefix != NULL && !strncmp((const char *)prefix, kName_Itms, kLength_Itms)) && (!strncmp((const char *)localname, kName_Artist, kLength_Artist) || !strncmp((const char *)localname, kName_Album, kLength_Album) || !strncmp((const char *)localname, kName_ReleaseDate, kLength_ReleaseDate))) )) 
        {
            importer.storingCharacters = YES;
            return;
        }
        
        if( prefix == NULL && (!strncmp((const char *)localname, kName_Image, kLength_Image)))
        {
            const char *key;
            NSString *val;  
            for (int i=0; i<nb_attributes; i++)
            {  
                key =(const char*)attributes[0] ;  
                val = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) 
                                             encoding:NSUTF8StringEncoding];  
                if (!strncmp((const char *)key, kName_src, kLength_src)) 
                {  
                    importer.currentItem.imageURLString=val;  
                }
                [val release];  
                attributes += 5;
            }
        }
    }
}

/*
 This callback is invoked when the parse reaches the end of a node. At that point we finish processing that node,
 if it is of interest to us. For "item" nodes, that means we have completed parsing a Song object. We pass the song
 to a method in the superclass which will eventually deliver it to the delegate. For the other nodes we
 care about, this means we have all the character data. The next step is to create an NSString using the buffer
 contents and store that with the current Song object.
 */
static void endElementSAX(void *parsingContext, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) 
{    
    YummyGroupImporter *importer = (YummyGroupImporter *)parsingContext;
    //if (importer.parsingAnItem == NO) return;
    if (prefix == NULL) 
    {
        if (!strncmp((const char *)localname, kName_Item, kLength_Item)) 
        {
            [importer.currentGroup addYummItem:importer.currentItem];
            [importer finishedCurrentItem];
        } 
        else if (!strncmp((const char *)localname, kName_Title, kLength_Title)) 
        {
            importer.currentItem.title = importer.currentString;
        } 
        else if (!strncmp((const char *)localname, kName_Group, kLength_Group)) 
        {
            NSLog(@"add group");
            [importer.groups addObject:importer.currentGroup];
            importer.currentGroup = nil;
        } 
//        else if (!strncmp((const char *)localname, kName_Category, kLength_Category)) 
//        {
//            double before = [NSDate timeIntervalSinceReferenceDate];
//            Category *category = [importer.theCache categoryWithName:importer.currentString];
//            double delta = [NSDate timeIntervalSinceReferenceDate] - before;
//            lookuptime += delta;
//            importer.currentItem.category = category;
//        }
    } 
//    else if (!strncmp((const char *)prefix, kName_Itms, kLength_Itms)) {
//        if (!strncmp((const char *)localname, kName_Artist, kLength_Artist)) {
//            importer.currentSong.artist = importer.currentString;
//        } else if (!strncmp((const char *)localname, kName_Album, kLength_Album)) {
//            importer.currentSong.album = importer.currentString;
//        } else if (!strncmp((const char *)localname, kName_ReleaseDate, kLength_ReleaseDate)) {
//            NSString *dateString = importer.currentString;
//            importer.currentSong.releaseDate = [importer.dateFormatter dateFromString:dateString];
//        }
//    }
    importer.storingCharacters = NO;
}

/*
 This callback is invoked when the parser encounters character data inside a node. The importer class determines how to use the character data.
 */
static void charactersFoundSAX(void *parsingContext, const xmlChar *characterArray, int numberOfCharacters) 
{
    YummyGroupImporter *importer = (YummyGroupImporter *)parsingContext;
    // A state variable, "storingCharacters", is set when nodes of interest begin and end. 
    // This determines whether character data is handled or ignored. 
    if (importer.storingCharacters == NO) return;
    [importer appendCharacters:(const char *)characterArray length:numberOfCharacters];
}

/*
 A production application should include robust error handling as part of its parsing implementation.
 The specifics of how errors are handled depends on the application.
 */
static void errorEncounteredSAX(void *parsingContext, const char *errorMessage, ...) 
{
    // Handle errors as appropriate for your application.
    NSCAssert(NO, @"Unhandled error encountered during SAX parse.");
}

// The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
// that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = 
{
NULL,                       /* internalSubset */
NULL,                       /* isStandalone   */
NULL,                       /* hasInternalSubset */
NULL,                       /* hasExternalSubset */
NULL,                       /* resolveEntity */
NULL,                       /* getEntity */
NULL,                       /* entityDecl */
NULL,                       /* notationDecl */
NULL,                       /* attributeDecl */
NULL,                       /* elementDecl */
NULL,                       /* unparsedEntityDecl */
NULL,                       /* setDocumentLocator */
NULL,                       /* startDocument */
NULL,                       /* endDocument */
NULL,                       /* startElement*/
NULL,                       /* endElement */
NULL,                       /* reference */
charactersFoundSAX,         /* characters */
NULL,                       /* ignorableWhitespace */
NULL,                       /* processingInstruction */
NULL,                       /* comment */
NULL,                       /* warning */
errorEncounteredSAX,        /* error */
NULL,                       /* fatalError //: unused error() get all the errors */
NULL,                       /* getParameterEntity */
NULL,                       /* cdataBlock */
NULL,                       /* externalSubset */
XML_SAX2_MAGIC,             //
NULL,
startElementSAX,            /* startElementNs */
endElementSAX,              /* endElementNs */
NULL,                       /* serror */
};
