//
//  YummyMetroViewData.h
//  Yummy
//
//  Created by ttron on 2/6/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YummyMetroView.h"

@interface YummyMetroViewData : NSObject <NSCopying, NSMutableCopying>
{
	YummyMetroView *				__unsafe_unretained _gridView;				// weak reference
	CGSize						_boundsSize;
	//AQGridViewLayoutDirection	_layoutDirection;
	CGSize						_desiredCellSize;		// NB: 'cell' here means a grid cell -- i.e. constant size, tessellating
	CGSize						_actualCellSize;
	
	CGFloat						_padding;
	
	NSUInteger					_numberOfItems;
	NSUInteger					_reorderedIndex;
}

- (id) initWithGridView: (YummyMetroView *) gridView;

@property (nonatomic) NSUInteger numberOfItems;

@property (nonatomic) CGFloat padding;
//@property (nonatomic) AQGridViewLayoutDirection layoutDirection;

// notify this object of changes to the layout parameters
- (void) gridViewDidChangeBoundsSize: (CGSize) boundsSize;

// nabbed from UITableViewRowData-- will we need something like this?
//@property (nonatomic) NSUInteger reorderedIndex;

// Turning view locations into item indices
- (NSUInteger) itemIndexForPoint: (CGPoint) point;
- (BOOL) pointIsInLastRow: (CGPoint) point;

// grid cell sizes-- for the layout calculations
- (void) setDesiredCellSize: (CGSize) desiredCellSize;
- (CGSize) cellSize;

// metrics used within the scroll view
- (CGRect) rectForEntireGrid;
- (CGSize) sizeForEntireGrid;
- (NSUInteger) numberOfItemsPerRow;

- (CGRect) cellRectAtIndex: (NSUInteger) index;
- (CGRect) cellRectForPoint: (CGPoint) point;
- (NSIndexSet *) indicesOfCellsInRect: (CGRect) rect;		// NB: Grid Cells only-- AQGridViewCells might not actually intersect
@end