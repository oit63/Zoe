//
//  YummyRepo.m
//  Yummy OnMe
//
//  Created by ttron on 3/14/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "YummyRepo.h"

@interface CacheNode : NSObject 
{
    NSManagedObjectID *objectID;
    NSUInteger accessCounter;
}

@property (nonatomic, retain) NSManagedObjectID *objectID;
@property NSUInteger accessCounter;

@end

@implementation CacheNode

@synthesize objectID, accessCounter;

- (void)dealloc 
{
    [objectID release];
    [super dealloc];
}

@end


@implementation YummyRepo

static YummyRepo *sharedInstance=nil;

@synthesize managedObjectContext, cacheSize, cache, persistentStoreCoordinator;


+(YummyRepo *) sharedInstance
{
    if(!sharedInstance)
        sharedInstance=[[self alloc]init];
    return sharedInstance;
}

+(id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(sharedInstance==nil)
        {
            sharedInstance=[super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}


- (id)init 
{
    self = [super init];
    if (self != nil) 
    {
        cacheSize = 15;
        cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (cacheHitCount > 0) NSLog(@"average cache hit cost:  %f", totalCacheHitCost/cacheHitCount);
    if (cacheMissCount > 0) NSLog(@"average cache miss cost: %f", totalCacheMissCost/cacheMissCount);
    
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [cache release];
    [super dealloc];
}

// Implement the "set" accessor rather than depending on @synthesize so that we can set up registration
// for context save notifications.
- (void)setManagedObjectContext:(NSManagedObjectContext *)aContext 
{
    if (managedObjectContext) 
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        [managedObjectContext release];
    }
    managedObjectContext = [aContext retain];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
}


- (void)managedObjectContextDidSave:(NSNotification *)notification 
{
    CacheNode *cacheNode = nil;
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in cache) 
    {
        cacheNode = [cache objectForKey:key];
        if ([cacheNode.objectID isTemporaryID]) 
        {
            [keys addObject:key];
        }
    }
    [cache removeObjectsForKeys:keys];
}



-(NSArray*) queryEntities:modelName predicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *context=self.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:modelName
											  inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    if(predicate != nil)
        [request setPredicate:predicate];
	
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) 
    {
        NSLog(@"There was an error!");
        return nil;
        // Do whatever error handling is appropriate
    }
	
    [request release];	
    return objects;
}

-(void) persistEntities:(id)modelName objects:(NSArray *)objects
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    if(objects)
        for (NSObject* object in objects) 
        {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:modelName
                                                      inManagedObjectContext:context];
            [request setEntity:entityDescription];
            
            NSManagedObject *theLine = nil;
            
            NSArray *objects_ = [context executeFetchRequest:request
                                                       error:&error];
            
            if (objects == nil) 
            {
                NSLog(@"There was an error!");
                // Do whatever error handling is appropriate
            }
            
            if ([objects_ count] > 0)
                theLine = [objects_ objectAtIndex:0];
            else
                theLine = [NSEntityDescription
                           insertNewObjectForEntityForName:modelName
                           inManagedObjectContext:context];
            [request release];
        }
    [context save:&error];
}
@end