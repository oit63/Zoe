#import "ParseOperation.h"
#import "YummyOnMeAppDelegate.h"

static NSString *kIDStr     = @"uid";
static NSString *kTitleStr   = @"title";
static NSString *kImageStr  = @"image";
static NSString *kGroupStr  = @"group";
static NSString *kItemStr  = @"item";
static NSString *kTypeStr  = @"tp";


@interface ParseOperation ()
@property (nonatomic, assign) id <ParseOperationDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) YummyGroup *workingGroup;
@property (nonatomic, retain) YummyItem *workingItem;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
@end

@implementation ParseOperation

@synthesize delegate, dataToParse, workingArray, workingGroup,workingItem, workingPropertyString, elementsToParse, storingCharacterData;
@synthesize insertionContext;
@synthesize yummyItemEntityDescription;
@synthesize yummyGroupEntityDescription;
@synthesize persistentStoreCoordinator;

- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.elementsToParse = [NSArray arrayWithObjects:kTitleStr, kImageStr, nil];
    }
    return self;
}

- (void)dealloc
{
    [dataToParse release];
    [workingGroup release];
    [workingItem release];
    [workingPropertyString release];
    [workingArray release];
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
	// desirable because it gives less control over the network, particularly in responding to
	// connection errors.
    //
    //NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://192.168.8.1:8080/cc.tsst.onme.yummy/xml/home.xml"]];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        NSLog(@"save");
        NSError *saveError = nil;
        //NSAssert1([self.insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
        if(![self.insertionContext save:&saveError ])
        {
            NSLog(@"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
        }
        
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    
    [parser release];
	[pool release];
}


#pragma mark -
#pragma mark RSS processing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict
{
    // entry: { id (link), im:name (app name), im:image (variable height) }
    //
    if ([elementName isEqualToString:kGroupStr])
	{
        //self.workingGroup = [[[YummyGroup alloc] init] autorelease];
        NSString *sid = [attributeDict objectForKey:@"sid"];
        NSString *bgColorString = [attributeDict objectForKey:@"bgcolor"];
        //NSLog(@"Group with sid:%@",sid);
        self.workingGroup.sid=[sid integerValue];
        self.workingGroup.bgColorString=bgColorString;
        bgColorString=nil;
        return;
    }
    
    if ([elementName isEqualToString:kItemStr]) 
    {
        //self.workingItem = [[[YummyItem alloc] init] autorelease];
        NSString *uid = [attributeDict objectForKey:kIDStr];
        self.workingItem.uid=uid;
        NSString *tp = [attributeDict objectForKey:kTypeStr];
        [self.workingItem setTypeString:tp];
        self.workingItem.bgColorString=[self.workingGroup.bgColorString copy];
        return;
    }
    
    if ([elementName isEqualToString:kImageStr]) 
    {
        NSString *imageURLString = [attributeDict objectForKey:@"src"];
        //NSLog(@"Item with src:%@",imageURLString);
        self.workingItem.imageURLString=imageURLString;
    }
    
    storingCharacterData = [elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
{
    if (storingCharacterData)
    {
        if (self.workingItem)
        {
            NSString *trimmedString = [workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [workingPropertyString setString:@""];  // clear the string for next time
            if ([elementName isEqualToString:kTitleStr])
            {
                //NSLog(@"Item with title:%@",trimmedString);
                self.workingItem.title = trimmedString;
            }
        }
    }

    
    if ([elementName isEqualToString:kGroupStr])
    {
        
        if(self.workingGroup)
        {
            [self.workingArray addObject:self.workingGroup];  
            self.workingGroup =nil;
            return;
        }
    }
    
    if ([elementName isEqualToString:kItemStr])
    {  
        if(self.workingItem)
        {
            [self.workingGroup addYummItem:self.workingItem];
            self.workingItem = nil;
            return;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingCharacterData)
    {
        [workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}


-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    return ((YummyOnMeAppDelegate*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator;
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

- (YummyItem *) workingItem 
{
    if (workingItem == nil) 
    {
        workingItem = [[YummyItem alloc] initWithEntity:self.yummyItemEntityDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return workingItem;
}

- (YummyGroup *) workingGroup 
{
    if (workingGroup == nil) 
    {
        workingGroup = [[YummyGroup alloc] initWithEntity:self.yummyGroupEntityDescription insertIntoManagedObjectContext:self.insertionContext];
    }
    return workingGroup;
}

@end