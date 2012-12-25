//
//  YummyRepo.h
//  Yummy OnMe
//
//  Created by ttron on 3/6/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YummyRepo : NSObject
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectContext *managedObjectContext;
    // Number of objects that can be cached
    NSUInteger cacheSize;
    CGFloat totalCacheHitCost;
    CGFloat totalCacheMissCost;
    NSUInteger cacheHitCount;
    NSUInteger cacheMissCount;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property NSUInteger cacheSize;
@property (nonatomic, retain) NSMutableDictionary *cache;


+ (YummyRepo *) sharedInstance;

- (NSArray*) queryEntities:(NSString*)modelName predicate:(NSPredicate*) predicate;
- (void) persistEntities:modelName objects:(NSArray *)objects;
@end