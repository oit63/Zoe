//
//  YummyMetroViewData.m
//  Yummy
//
//  Created by ttron on 2/6/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyMetroViewData.h"
#import "YummyMetroView.h"

@interface YummyMetroViewData (YummyMetroViewDataPrivate)
- (void) fixDesiredCellSizeForWidth: (CGFloat) width;
@end

@implementation YummyMetroViewData

@synthesize  numberOfItems=_numberOfItems, padding=_padding;
//bottomPadding=_bottomPadding, leftPadding=_leftPadding, rightPadding=_rightPadding, 
//layoutDirection=_layoutDirection,reorderedIndex=_reorderedIndex;

- (id) initWithGridView: (YummyMetroView *) gridView
{
	self = [super init];
	if ( self == nil )
		return ( nil );
	
	_gridView = gridView;
	_boundsSize = gridView.bounds.size;
    _padding=0;
	
	return ( self );
}

- (id) copyWithZone: (NSZone *) zone
{
	YummyMetroViewData * theCopy = [[YummyMetroViewData allocWithZone: zone] initWithGridView: _gridView];
	theCopy->_desiredCellSize = _desiredCellSize;
	theCopy->_actualCellSize = _actualCellSize;
	//theCopy->_layoutDirection = _layoutDirection;
    theCopy->_padding = _padding;
	theCopy->_numberOfItems = _numberOfItems;
	theCopy->_reorderedIndex = _reorderedIndex;
	return ( theCopy );
}

- (id) mutableCopyWithZone: (NSZone *) zone
{
	return ( [self copyWithZone: zone] );
}

- (void) gridViewDidChangeBoundsSize: (CGSize) boundsSize
{
	_boundsSize = boundsSize;
	//if ( _layoutDirection == AQGridViewLayoutDirectionVertical )
	//	[self fixDesiredCellSizeForWidth: boundsSize.width];
}

- (NSUInteger) itemIndexForPoint: (CGPoint) point
{
	// adjust for top padding
	point.y -= _padding;
	point.x -= _padding;
	
	// get a count of all rows before the one containing the point
	NSUInteger y = (NSUInteger)floorf(point.y);
	NSUInteger row = y / (NSUInteger)_actualCellSize.height;
	
	// now column
	NSUInteger x = (NSUInteger)floorf(point.x);
	NSUInteger col = x / (NSUInteger)_actualCellSize.width;
	
	NSUInteger result = (row * [self numberOfItemsPerRow]) + col;
	if ( result >= self.numberOfItems )
		result = NSNotFound;
	
	return ( result );
}

- (BOOL) pointIsInLastRow: (CGPoint) point
{
	CGRect rect = [self rectForEntireGrid];
	//if ( _layoutDirection == AQGridViewLayoutDirectionVertical )
		return ( point.y >= (rect.size.height - _actualCellSize.height) );
	
	// 'else'
	return ( point.x >= (rect.size.width - _actualCellSize.width) );
}

- (CGRect) cellRectForPoint: (CGPoint) point
{
	return ( [self cellRectAtIndex: [self itemIndexForPoint: point]] );
}

- (void) setDesiredCellSize: (CGSize) desiredCellSize
{
	_desiredCellSize = desiredCellSize;
	//if ( _layoutDirection == AQGridViewLayoutDirectionVertical )
		//[self fixDesiredCellSizeForWidth: _boundsSize.width];
	//else
		_actualCellSize = _desiredCellSize;
}

//- (void) setLayoutDirection: (AQGridViewLayoutDirection) direction
//{
//	if ( direction == AQGridViewLayoutDirectionVertical )
//		[self fixDesiredCellSizeForWidth: _boundsSize.width];
//	else
//		_actualCellSize = _desiredCellSize;
//	_layoutDirection = direction;
//}

- (CGSize) cellSize
{
	return ( _actualCellSize );
}

- (CGRect) rectForEntireGrid
{
	CGRect rect;
	//rect.origin.x = _leftPadding;
	//rect.origin.y = _topPadding;
	rect.size = [self sizeForEntireGrid];
	return ( rect );
}

- (CGSize) sizeForEntireGrid
{
	NSUInteger numPerRow = [self numberOfItemsPerRow];
    if ( numPerRow == 0 )       // avoid a divide-by-zero exception
        return ( CGSizeZero );
	NSUInteger numRows = _numberOfItems / numPerRow;
	if ( _numberOfItems % numPerRow != 0 )
		numRows++;
	
	CGFloat height = ( ((CGFloat)ceilf((CGFloat)numRows * _actualCellSize.height)));// + _topPadding + _bottomPadding );
	if (height < _gridView.bounds.size.height)
		height = _gridView.bounds.size.height;
	
	return ( CGSizeMake(((CGFloat)ceilf(_actualCellSize.width * numPerRow)),height));// + _leftPadding + _rightPadding, height) );
}

- (NSUInteger) numberOfItemsPerRow
{
	//if ( _layoutDirection == AQGridViewLayoutDirectionVertical )
	return ( (NSUInteger)floorf(_boundsSize.width / _actualCellSize.width) );
	
	// work out how many rows we can fit
//	NSUInteger rows = (NSUInteger)floorf(_boundsSize.height / _actualCellSize.height);
//	if (0 == rows) 
//    {
//		rows = 1;
//	}
//	NSUInteger cols = _numberOfItems / rows;
//	if ( _numberOfItems % rows != 0 )
//		cols++;
//	
//	return ( cols );	
}

- (CGRect) cellRectAtIndex: (NSUInteger) index
{
	NSUInteger numPerRow = [self numberOfItemsPerRow];
    if ( numPerRow == 0 )       // avoid a divide-by-zero exception
        return ( CGRectZero );
	NSUInteger skipRows = index / numPerRow;
	NSUInteger skipCols = index % numPerRow;
	
	CGRect result = CGRectZero;
	result.origin.x = _actualCellSize.width * (CGFloat)skipCols + _padding;
	result.origin.y = (_actualCellSize.height  * (CGFloat)skipRows) + _padding;
	result.size = _actualCellSize;
	
	return ( result );
}

- (NSIndexSet *) indicesOfCellsInRect: (CGRect) aRect
{
	NSMutableIndexSet * result = [NSMutableIndexSet indexSet];
	NSUInteger numPerRow = [self numberOfItemsPerRow];
	
	for ( NSUInteger i = 0; i < _numberOfItems; i++ )
	{
		CGRect cellRect = [self cellRectAtIndex: i];
		
		if ( CGRectGetMaxY(cellRect) < CGRectGetMinY(aRect) )
		{
			// jump forward to the next row
			i += (numPerRow - 1);
			continue;
		}
		
		if ( CGRectIntersectsRect(cellRect, aRect) )
		{
			[result addIndex: i];
			if ( (CGRectGetMaxY(cellRect) > CGRectGetMaxY(aRect)) &&
                (CGRectGetMaxX(cellRect) > CGRectGetMaxX(aRect)) )
			{
				// passed the bottom-right edge of the given rect
				break;
			}
		}
	}
	return ( result );
}

@end

@implementation YummyMetroViewData (YummyMetroViewDataPrivate)

- (void) fixDesiredCellSizeForWidth: (CGFloat) width
{
    // Much thanks to Brandon Sneed (@bsneed) for the following new algorithm, reduced to two floating-point divisions -- that's O(1) folks!
	CGFloat w = floorf(width);// - _leftPadding - _rightPadding);
	CGFloat dw = floorf(_desiredCellSize.width);
    CGFloat multiplier = floorf( w / dw );
	_actualCellSize.width = floorf( w / multiplier );
	_actualCellSize.height = _desiredCellSize.height;
}

@end