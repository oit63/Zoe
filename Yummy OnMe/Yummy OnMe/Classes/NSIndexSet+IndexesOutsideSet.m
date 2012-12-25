//
//  NSIndexSet+AQIndexesOutsideSet.m
//  Kobov3
//
//  Created by Jim Dovey on 10-06-22.
//  Copyright 2010 Kobo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSIndexSet+IndexesOutsideSet.h"

@implementation NSIndexSet (IndexesOutsideSet)

- (NSIndexSet *) aq_indexesOutsideIndexSet: (NSIndexSet *) otherSet
{
	NSMutableIndexSet * mutable = [self mutableCopy];
	[mutable removeIndexes: otherSet];
	NSIndexSet * result = [mutable copy];
	return ( result );
}

@end
