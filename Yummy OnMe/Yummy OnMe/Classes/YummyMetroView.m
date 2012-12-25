//
//  YummyMetroView.m
//  Yummy
//
//  Created by ttron on 1/29/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyMetroView.h"
#import "YummyMetroViewData.h"
#import "NSIndexSet+IndexesOutsideSet.h"
#import "YummyCell.h"
#import "Logit.h"
#import "YummyMetroViewController.h"
#import "YummyOnMeAppDelegate.h"
#import "YummyMetroViewXMLDataSource.h"

//#import <libkern/OSAtomic.h>
//#import <objc/objc.h>
//#import <objc/runtime.h>


// Lightweight object class for touch selection parameters
@interface UserSelectItemIndexParams : NSObject
{
    NSUInteger _indexNum;
    NSUInteger _numFingers;
};
@property (nonatomic, assign) NSUInteger indexNum;
@property (nonatomic, assign) NSUInteger numFingers;
@end

@implementation UserSelectItemIndexParams
@synthesize indexNum = _indexNum;
@synthesize numFingers = _numFingers;
@end

@implementation YummyMetroView

NSArray * __sortDescriptors;

- (void) sortVisibleCellList
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		__sortDescriptors = [[NSArray alloc] initWithObjects: [[NSSortDescriptor alloc] initWithKey: @"displayIndex" ascending: YES], nil];
    });
    
	[_visibleCells sortUsingDescriptors: __sortDescriptors];
}


@synthesize dataSource=_dataSource;
@synthesize animatingIndices=_animatingIndices;
@synthesize viewData=_viewData;

- (void) _sharedInit
{
    _viewData = [[YummyMetroViewData alloc] initWithGridView: self];
	[_viewData setDesiredCellSize: CGSizeMake(256, 256)];
    _reusableYummyCells = [[NSMutableDictionary alloc] init];
    _visibleCells = [[NSMutableArray alloc] init];
    
    _selectedIndex = NSNotFound;
	_pendingSelectionIndex = NSNotFound;
        
    //[view setBackgroundColor:[UIColor blackColor]];
    //[self setShowsVerticalScrollIndicator:NO];
    self.backgroundColor=[UIColor blackColor];
}

- (id)initWithFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
	if ( self == nil )
		return ( nil );
    
	[self _sharedInit];
    
	return ( self );
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
	self = [super initWithCoder: aDecoder];
	if ( self == nil )
		return ( nil );
    
	[self _sharedInit];
    
	return ( self );
}




- (void) setDelegate: (id<YummyMetroViewDelegate>) obj
{
	if ( (obj != nil) && ([obj conformsToProtocol: @protocol(YummyMetroViewDelegate)] == NO ))
		[NSException raise: NSInvalidArgumentException format: @"Argument to -setDelegate must conform to the YummyMetroViewDelegate protocol"];
	[super setDelegate: obj];
    
//	_flags.delegateWillDisplayCell = [obj respondsToSelector: @selector(gridView:willDisplayCell:forItemAtIndex:)];
//	_flags.delegateWillSelectItem = [obj respondsToSelector: @selector(gridView:willSelectItemAtIndex:)];
//    _flags.delegateWillSelectItemMultiTouch = [obj respondsToSelector: @selector(gridView:willSelectItemAtIndex:numFingersTouch:)];
//	_flags.delegateWillDeselectItem = [obj respondsToSelector: @selector(gridView:willDeselectItemAtIndex:)];
//	_flags.delegateDidSelectItem = [obj respondsToSelector: @selector(gridView:didSelectItemAtIndex:)];
//    _flags.delegateDidSelectItemMultiTouch = [obj respondsToSelector: @selector(gridView:didSelectItemAtIndex:numFingersTouch:)];
//	_flags.delegateDidDeselectItem = [obj respondsToSelector: @selector(gridView:didDeselectItemAtIndex:)];
//	_flags.delegateGestureRecognizerActivated = [obj respondsToSelector: @selector(gridView:gestureRecognizer:activatedForItemAtIndex:)];
//	_flags.delegateAdjustGridCellFrame = [obj respondsToSelector: @selector(gridView:adjustCellFrame:withinGridCellFrame:)];
//	_flags.delegateDidEndUpdateAnimation = [obj respondsToSelector:@selector(gridViewDidEndUpdateAnimation:)];
}

- (id<YummyMetroViewDelegate>) delegate
{
	id obj = [super delegate];
	if ( [obj conformsToProtocol: @protocol(YummyMetroViewDelegate)] == NO )
		return ( nil );
	return ( obj );
}


- (void) setDataSource: (id<YummyMetroViewDataSource>) obj
{
	if ((obj != nil) && ([obj conformsToProtocol: @protocol(YummyMetroViewDataSource)] == NO ))
		[NSException raise: NSInvalidArgumentException format: @"Argument to -setDataSource must conform to the YummyMetroViewDataSource protocol"];
    
	_dataSource = obj;
    [_dataSource setViewer:self];
    
	//_flags.dataSourceGridCellSize = [obj respondsToSelector: @selector(portraitGridCellSizeForGridView:)];
}

- (void) delegateWillDisplayCell: (YummyCell *) cell atIndex: (NSUInteger) index
{
//	if ( cell.separatorStyle == YummyCellSeparatorStyleSingleLine )
//	{
		// determine which edges need a separator
//		YummyCellSeparatorEdge edge = 0;
//		if ( (index % self.numberOfColumns) != self.numberOfColumns-1 )
//		{
//			edge |= YummyCellSeparatorEdgeRight;
//		}
//		//if ( index <= (viewData.numberOfItems - self.numberOfColumns) )
//		{
//			edge |= YummyCellSeparatorEdgeBottom;
//		}
//        
//		cell.separatorEdge = edge;
//	}
    
    //NSLog( @"Displaying cell at index %lu", (unsigned long) index );
    
//	if ( _flags.delegateWillDisplayCell == 0 )
//		return;
    
	//[self.delegate gridView: self willDisplayCell: cell forItemAtIndex: index];
}


- (YummyCell *) dequeueReusableCellWithIdentifier: (NSString *) reuseIdentifier
{
	NSMutableSet * cells= [_reusableYummyCells objectForKey: reuseIdentifier];
	YummyCell * cell = [cells anyObject];
	if ( cell == nil )
		return ( nil );
	[cell prepareForReuse];
	[cells removeObject: cell];
	return ( cell );
}

- (void) enqueueReusableCells: (NSArray *) reusableYummyCells
{
	for ( YummyCell * cell in reusableYummyCells )
	{
		NSMutableSet * reuseSet = [_reusableYummyCells objectForKey: cell.reuseIdentifier];
		if ( reuseSet == nil )
		{
			reuseSet = [[NSMutableSet alloc] initWithCapacity: 32];
			[_reusableYummyCells setObject: reuseSet forKey: cell.reuseIdentifier];
		}
		else if ( [reuseSet member: cell] == cell )
		{
			NSLog( @"Warning: tried to add duplicate gridview cell" );
			continue;
		}
        
		[reuseSet addObject: cell];
	}
}

- (void) reloadData
{
    _viewData.numberOfItems = [_dataSource numberOfItemsInGridView: self];    
	// update our content size as appropriate
	self.contentSize = [_viewData sizeForEntireGrid];
    
    // fix up the visible index list
    NSUInteger cutoff = MAX(0, _viewData.numberOfItems-_visibleIndexRange.length);
    _visibleIndexRange.location = MIN(_visibleIndexRange.location, cutoff);
	_visibleIndexRange.length = 0;

    
    
	// remove all existing cells
	[_visibleCells makeObjectsPerformSelector: @selector(removeFromSuperview)];
	[self enqueueReusableCells: _visibleCells];
	[_visibleCells removeAllObjects];
        
	// -layoutSubviews will update the visible cell list
	// layout -- no animation
	[self setNeedsLayout];
}


- (CGRect) gridViewVisibleBounds
{
	CGRect result = CGRectZero;
	result.origin = self.contentOffset;
	result.size   = self.bounds.size;
    //NSLog(@"gridViewVisibleBounds(%f,%f,%f,%f)",result.origin.x,result.origin.y,result.size.width,result.size.height);
	return ( result );
}

- (void)doAddVisibleCell: (UIView *)cell
{
	[_visibleCells addObject: cell];
	// updated: if we're adding it to our visibleCells collection, really it should be in the gridview.
	if ( cell.superview == nil )
	{
		NSLog( @"Visible cell not in gridview - adding" );
//		if ( _backgroundView.superview == self )
//			[self insertSubview: cell aboveSubview: _backgroundView];
//		else
			[self insertSubview: cell atIndex: 0];
	}
}





- (CGRect) fixCellFrame: (CGRect) cellFrame forGridRect: (CGRect) gridRect
{
    //	if ( _flags.resizesCellWidths == 1 )
    //	{
    //		cellFrame = gridRect;
    //	}
    //	else
    //	{
    //NSLog(@"before#fixedCellFrame(%f,%f,%f,%f)",cellFrame.origin.x,cellFrame.origin.y,cellFrame.size.width,cellFrame.size.height);

    
    if ( cellFrame.size.width > gridRect.size.width )
        cellFrame.size.width = gridRect.size.width;
    if ( cellFrame.size.height > gridRect.size.height )
        cellFrame.size.height = gridRect.size.height;
    cellFrame.origin.x = gridRect.origin.x + floorf( (gridRect.size.width - cellFrame.size.width) * 0.5 );
    cellFrame.origin.y = gridRect.origin.y + floorf( (gridRect.size.height - cellFrame.size.height) * 0.5 );
    
    //NSLog(@"after#fixedCellFrame(%f,%f,%f,%f)",cellFrame.origin.x,cellFrame.origin.y,cellFrame.size.width,cellFrame.size.height);
    //	}
    
	// let the delegate update it if appropriate
	//if ( _flags.delegateAdjustGridCellFrame )
    //cellFrame = [self.delegate gridView: self adjustCellFrame: cellFrame withinGridCellFrame: gridRect];
    
	return ( cellFrame );
}

- (void) layoutCellsInVisibleCellRange: (NSRange) range
{
    NSLog(@"layoutCellsInVisibleCellRange(%d,%d)",range.location,range.length);
	NSParameterAssert(range.location + range.length <= [_visibleCells count]);		
	@autoreleasepool 
    {
		NSArray * layoutList = [_visibleCells subarrayWithRange: range];
        NSInteger count=[layoutList count];
        NSLog(@"visible count:%d",count);
		for ( YummyCell * cell in layoutList )
		{
			//if ( [_animatingIndices containsIndex: cell.displayIndex] )
				//continue;		// don't adjust layout of something that is animating around
            
			CGRect gridRect = [_viewData cellRectAtIndex: cell.displayIndex];
			CGRect cellFrame = cell.frame;
            
			cell.frame = [self fixCellFrame: cellFrame forGridRect: gridRect];
            cellFrame=cell.frame;
			//cell.selected = (cell.displayIndex == _selectedIndex);
		}
	}
}

- (void) layoutAllCells
{
	[self sortVisibleCellList];
	NSRange range = NSMakeRange(0, _visibleIndexRange.length);
	[self layoutCellsInVisibleCellRange: range];
}



- (YummyCell *) createPreparedCellForIndex: (NSUInteger) index usingGridData: (YummyMetroViewData *) gridData
{
	[UIView setAnimationsEnabled: NO];
	YummyCell * cell = [_dataSource gridView: self cellForItemAtIndex: index];
	//cell.separatorStyle = _flags.separatorStyle;
	//cell.editing = self.editing;
	cell.displayIndex = index;
    
	cell.frame = [self fixCellFrame: cell.frame forGridRect: [gridData cellRectAtIndex: index]];
    //[cell setFrame:[self fixCellFrame: cell.frame forGridRect: [gridData cellRectAtIndex: index]]];
    //	if ( _backgroundView.superview == self )
    //		[self insertSubview: cell aboveSubview: _backgroundView];
    //	else
    [self insertSubview: cell atIndex: 0];
    [UIView setAnimationsEnabled: YES];
	return ( cell );
}

- (YummyCell *) createPreparedCellForIndex: (NSUInteger) index
{
    return ( [self createPreparedCellForIndex: index usingGridData: _viewData] );
}


- (void) updateVisibleGridCellsNow
{
    if ( _reloadingSuspendedCount > 0 )
        return;
    
    _reloadingSuspendedCount++;
    
    @autoreleasepool 
    {
        NSIndexSet * newVisibleIndices = [_viewData indicesOfCellsInRect: [self gridViewVisibleBounds]];
        
        //        ShowIndexSet(@"newVisibleIndices",newVisibleIndices);
        //        ShowRange(@"_visibleIndexRange",_visibleIndexRange);
        //        NSMutableString *str=[[NSMutableString alloc]init];
        //        NSUInteger i, count = [_visibleCells count];
        //        for ( i = 0; i < count; i++ )
        //        {
        //            YummyCell * cell = [_visibleCells objectAtIndex: i];
        //            [str appendString:[NSString stringWithFormat:@"%d,",cell.displayIndex]];
        //        }
        //        NSLog(@"_visibleCells[%@]",str);
        //        
        
        BOOL enableAnim = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled: NO];
        @try
        {
            // a couple of simple tests
            // TODO: if we replace _visibleIndices with an index set, this comparison will have to change
            if ( ([_visibleCells count] != [newVisibleIndices count]) ||
               ([newVisibleIndices countOfIndexesInRange: _visibleIndexRange] != _visibleIndexRange.length) )
            //if ([newVisibleIndices countOfIndexesInRange: _visibleIndices] != _visibleIndices.length)
            {
                // something has changed. Compute intersections and remove/add cells as required
                NSIndexSet * currentVisibleIndices = [NSIndexSet indexSetWithIndexesInRange: _visibleIndexRange];
                
                // index sets for removed and inserted items
                NSMutableIndexSet * removedIndices = nil, * insertedIndices = nil;
                
                // handle the simple case first
                // TODO: if we replace _visibleIndices with an index set, this comparison will have to change
                if ( [currentVisibleIndices intersectsIndexesInRange: _visibleIndexRange] == NO )
                {
                    removedIndices = [currentVisibleIndices mutableCopy];
                    insertedIndices = [newVisibleIndices mutableCopy];
                }
                else	// more complicated -- compute negative intersections
                {
                    removedIndices = [[currentVisibleIndices aq_indexesOutsideIndexSet: newVisibleIndices] mutableCopy];
                    insertedIndices = [[newVisibleIndices aq_indexesOutsideIndexSet: currentVisibleIndices] mutableCopy];
                }
                
              
                //ShowIndexSet(@"removedIndices",removedIndices);
                //ShowIndexSet(@"insertedIndices",insertedIndices);
                
                
                if ( [removedIndices count] != 0 )
                {
                    NSMutableIndexSet * shifted = [removedIndices mutableCopy];
                    
                    // get an index set for everything being removed relative to items' locations within the visible cell list
                    [shifted shiftIndexesStartingAtIndex: [removedIndices firstIndex] by: 0 - (NSInteger)_visibleIndexRange.location];
                    //NSLog( @"Removed indices relative to visible cell list: %@", shifted );

                    NSUInteger index=[shifted firstIndex];
                    while(index != NSNotFound)
                    {
                        //NSLog(@"%i >= %i ?", index, [_visibleCells count]);
                        if (index >= [_visibleCells count]) 
                        {
                            [shifted removeIndex:index];
                        }
                        index=[shifted indexGreaterThanIndex: index];
                    }
                    
                    // pull out the cells for manipulation
                    NSMutableArray * removedCells = [[_visibleCells objectsAtIndexes: shifted] mutableCopy];
                    
                    // remove them from the visible list
                    [_visibleCells removeObjectsInArray: removedCells];
                    //NSLog( @"After removals, visible cells count = %lu", (unsigned long)[_visibleCells count] );
                    
                    // don't need this any more
                    shifted = nil;
                    
                    // remove cells from the view hierarchy -- but only if they're not being animated by something else
                    //NSArray * animating = [[self.animatingCells valueForKey: @"animatingView"] allObjects];
                    //if ( animating != nil )
                      //  [removedCells removeObjectsInArray: animating];
                    
                    // these are not being displayed or animated offscreen-- take them off the screen immediately
                    [removedCells makeObjectsPerformSelector: @selector(removeFromSuperview)];
                    
                    // put them into the cell reuse queue
                    [self enqueueReusableCells: removedCells];                
                }
                
                if ( [insertedIndices count] != 0 )
                {
                    // some items are going in -- put them at the end and the sort function will move them to the right index during layout
                    // if any of these new indices correspond to animating cells (NOT UIImageViews) then copy them into the visible cell list
                    NSMutableIndexSet * animatingInserted = [insertedIndices mutableCopy];
                    
                    // compute the intersection of insertedIndices and _animatingIndices
                    NSUInteger idx = [insertedIndices firstIndex];
                    while ( idx != NSNotFound )
                    {
                        if ( [_animatingIndices containsIndex: idx] == NO )
                            [animatingInserted removeIndex: idx];                        
                        idx = [insertedIndices indexGreaterThanIndex: idx];
                    }
                    
//                    if ( [animatingInserted count] != 0 )
//                    {
//                        for ( AQGridViewAnimatorItem * item in _animatingCells )
//                        {
//                            if ( [newVisibleIndices containsIndex: item.index] == NO )
//                                continue;
//                            
//                            if ( [item.animatingView isKindOfClass: [YummyCell class]] )
//                            {
//                                // ensure this is in the visible cell list
//                                if ( [_visibleCells containsObject: item.animatingView] == NO )
//                                    //[_visibleCells addObject: item.animatingView];
//                                    [self doAddVisibleCell: item.animatingView];
//                            }
//                            else
//                            {
//                                // it's an image that's being moved, likely because it *was* going offscreen before
//                                // the user scrolled. Create a real cell, but hide it until the animation is complete.
//                                YummyCell * cell = [self createPreparedCellForIndex: idx];
//                                //[_visibleCells addObject: cell];
//                                [self doAddVisibleCell: cell];
//                                
//                                // we don't tell the delegate yet, we just hide it
//                                cell.hiddenForAnimation = YES;
//                            }
//                        }
//                        
//                        // remove these from the set of indices for which we will generate new cells
//                        [insertedIndices removeIndexes: animatingInserted];
//                    }
                    
                    
                    // insert cells for these indices
                    idx = [insertedIndices firstIndex];
                    while ( idx != NSNotFound )
                    {
                        YummyCell * cell = [self createPreparedCellForIndex: idx];
                        //[_visibleCells addObject: cell];
                        [self doAddVisibleCell: cell];
                        
                        // tell the delegate
                        [self delegateWillDisplayCell: cell atIndex: idx];
                        
                        idx = [insertedIndices indexGreaterThanIndex: idx];
                    }
                }
                
                if ( [_visibleCells count] > [newVisibleIndices count] )
                {
                    //NSLog( @"Have to prune visible cell list, I've still got extra cells in there!" );
//                    NSMutableIndexSet * animatingDestinationIndices = [[NSMutableIndexSet alloc] init];
//                    for ( AQGridViewAnimatorItem * item in _animatingCells )
//                    {
//                        [animatingDestinationIndices addIndex: item.index];
//                    }
                    
                    NSMutableIndexSet * toRemove = [[NSMutableIndexSet alloc] init];
                    NSMutableIndexSet * seen = [[NSMutableIndexSet alloc] init];
                    NSUInteger i, count = [_visibleCells count];
                    for ( i = 0; i < count; i++ )
                    {
                        YummyCell * cell = [_visibleCells objectAtIndex: i];
                        if ( [newVisibleIndices containsIndex: cell.displayIndex] == NO)// &&
                          //  [animatingDestinationIndices containsIndex: cell.displayIndex] == NO )
                        {
                            NSLog( @"Cell for index %lu is still in visible list, removing...", (unsigned long)cell.displayIndex );
                            [cell removeFromSuperview];
                            [toRemove addIndex: i];
                        }
                        else if ( [seen containsIndex: cell.displayIndex] )
                        {
                            NSLog( @"Multiple cells with index %lu found-- removing duplicate...", (unsigned long)cell.displayIndex );
                            [cell removeFromSuperview];
                            [toRemove addIndex: i];
                        }
                        
                        //[seen addIndex: cell.displayIndex];
                    }
                    
                    // all removed from superview, just need to remove from the list now
                    [_visibleCells removeObjectsAtIndexes: toRemove];
                }
                
                if ( [_visibleCells count] < [newVisibleIndices count] )
                {
                    NSLog( @"Visible cell list is missing some items!" );
                    
                    NSMutableIndexSet * visibleSet = [[NSMutableIndexSet alloc] init];
                    for ( YummyCell * cell in _visibleCells )
                    {
                        [visibleSet addIndex: cell.displayIndex];
                    }
                    
                    NSMutableIndexSet * missingSet = [newVisibleIndices mutableCopy];
                    [missingSet removeIndexes: visibleSet];
                    
                    NSLog( @"Got %lu missing indices", (unsigned long)[missingSet count] );
                    
                    NSUInteger idx = [missingSet firstIndex];
                    while ( idx != NSNotFound )
                    {
                        YummyCell * cell = [self createPreparedCellForIndex: idx];
                        //[_visibleCells addObject: cell];
                        [self doAddVisibleCell: cell];
                        
                        // tell the delegate
                        [self delegateWillDisplayCell: cell atIndex: idx];
                        
                        idx = [missingSet indexGreaterThanIndex: idx];
                    }
                    
                }
                
                // everything should match up now, so update the visible range
                _visibleIndexRange.location = [newVisibleIndices firstIndex];//@_@
                _visibleIndexRange.length   = [newVisibleIndices count];
                
              
                //ShowIndexSet(@"before:layoutAllCells():newVisibleIndices[%@]",newVisibleIndices);

                // layout these cells -- this will also sort the visible cell list
                [self layoutAllCells];
            }
        }
        @catch (id exception)
        {
            NSLog(@"error in updateVisiableGridCellsNow:%@",[exception localizedDescription]);
        }
        @finally
        {
            [UIView setAnimationsEnabled: enableAnim];
            _reloadingSuspendedCount--;
        }
    }
}

- (void) layoutSubviews
{
    if ( (_reloadingSuspendedCount == 0) && (!CGRectIsEmpty([self gridViewVisibleBounds])) )
	{
        [self updateVisibleGridCellsNow];
	}
}

- (NSUInteger) visibleCellListIndexForItemIndex: (NSUInteger) itemIndex
{
	return ( itemIndex - _visibleIndexRange.location );
}

- (NSUInteger) indexForItemAtPoint: (CGPoint) point
{
	return ( [_viewData itemIndexForPoint: point] );
}

- (YummyCell *) cellForItemAtIndex: (NSUInteger) index
{
	//if ( NSLocationInRange(index, _visibleIndices) == NO )
	//	return ( nil );
    
	// we don't clip to visible range-- when animating edits the visible cell list can contain extra items
	NSUInteger visibleCellListIndex = [self visibleCellListIndexForItemIndex: index];
	if ( visibleCellListIndex < [_visibleCells count] )
		return ( [_visibleCells objectAtIndex: visibleCellListIndex] );
	return ( nil );
}

- (void) _userSelectItemAtIndex: (UserSelectItemIndexParams*) params
{
	NSUInteger index = params.indexNum;
    NSUInteger numFingersCount = params.numFingers;
    NSLog(@"Tapped at %d cell",index);
    
    YummyCell *cell=[self cellForItemAtIndex:index];
    [cell touchAtPoint:CGPointMake(0, 0)];
    
//    NSString *urlStr=@"http://192.168.1.57:8080/cc.tsst.onme.yummy/rest/groups";
//    YummyMetroViewXMLDataSource *dataSource=[[YummyMetroViewXMLDataSource alloc] initFromUrl:[NSURL URLWithString:urlStr]];
//    [urlStr release];
//    [self setDataSource:dataSource];
//    [self reloadData];
    
    //	//[self unhighlightItemAtIndex: index animated: NO];
    //	if ( ([[self cellForItemAtIndex: index] isSelected]) && (self.requiresSelection == NO) )
    //		[self _deselectItemAtIndex: index animated: NO notifyDelegate: YES];
    //	else
    //		[self _selectItemAtIndex: index animated: NO scrollPosition: AQGridViewScrollPositionNone notifyDelegate: YES
    // numFingersTouch: numFingersCount];
	_pendingSelectionIndex = NSNotFound;
}

- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{  
    UITouch * touch = [touches anyObject];
	_touchBeganPosition = [touch locationInView: nil];
	if ( (touch != nil) && (_pendingSelectionIndex == NSNotFound) )
	{
		CGPoint pt = [touch locationInView: self];
//		UIView * hitView = [self _basicHitTest: pt withEvent: event];
//		_touchedContentView = hitView;
//        
//		// unhighlight anything not here
//		//if ( hitView != self )
//        //[self highlightItemAtIndex: NSNotFound animated: NO scrollPosition: AQGridViewScrollPositionNone];
//        
//		//if ( [self _canSelectItemContainingHitView: hitView] )
//		//{
        NSUInteger index = [self indexForItemAtPoint: pt];
        if ( index != NSNotFound )
        {
            _pendingSelectionIndex = index;
            NSLog(@"Touch at Cell:%d",index);
//            
//            // NB: In UITableView:
//            // if ( [self usesGestureRecognizers] && [self isDragging] ) skip next line
//            [self performSelector: @selector(_gridViewDeferredTouchesBegan:)
//                       withObject: [NSNumber numberWithUnsignedInteger: index]
//                       afterDelay: 0.0];
//        }
		}
	}
    NSLog(@"touch began at(%f,%f)",_touchBeganPosition.x,_touchBeganPosition.y);
	[super touchesBegan: touches withEvent: event];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    NSLog(@"touch end");
    
    // poor-man's goto
	do
	{
		if ( self.dragging )
			break;
        
		UITouch * touch = [touches anyObject];
		if ( touch == nil )
			break;
        
		CGPoint pt = [touch locationInView: self];
		//if ( (hitView != nil) && ([self _canSelectItemContainingHitView: hitView] == NO) )
		//	break;
        
		if ( _pendingSelectionIndex != [self indexForItemAtPoint: pt] )
			break;
        
		//if ( _flags.allowsSelection == 0 )
		//	break;
        
        NSSet *touchEventSet = [event allTouches];
        
		// run this on the next runloop tick
        UserSelectItemIndexParams* selectorParams = [[UserSelectItemIndexParams alloc] init];
        selectorParams.indexNum = _pendingSelectionIndex;
        selectorParams.numFingers = [touchEventSet count];
        [self performSelector: @selector(_userSelectItemAtIndex:)
				   withObject: selectorParams
                   afterDelay:0.0];
	} while (0);

	if ( _pendingSelectionIndex != NSNotFound )
		//[self unhighlightItemAtIndex: _pendingSelectionIndex animated: NO];
        _pendingSelectionIndex = NSNotFound;
}

- (void) touchesCancelled: (NSSet *) touches withEvent: (UIEvent *) event
{
    _pendingSelectionIndex = NSNotFound;
    //[self highlightItemAtIndex: NSNotFound animated: NO scrollPosition: AQGridViewScrollPositionNone];
    [super touchesCancelled: touches withEvent: event];
    //_touchedContentView = nil;
}

- (void) setContentOffset:(CGPoint) offset
{
	[super setContentOffset: offset];
}

- (void)setContentOffset: (CGPoint) contentOffset animated: (BOOL) animate
{
	// Call our super duper method
	[super setContentOffset: contentOffset animated: animate];
    
	// for long grids, ensure there are visible cells when scrolled to
	if (!animate)
	{
		[self updateVisibleGridCellsNow];
		/*if (![_visibleCells count])
         {
         NSIndexSet * newIndices = [viewData indicesOfCellsInRect: [self gridViewVisibleBounds]];
         [self updateForwardCellsForVisibleIndices: newIndices];
         }*/
	}
}

@end