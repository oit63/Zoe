//
//  YummyMetroView.h
//  Yummy
//
//  Created by ttron on 1/29/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YummyCell.h"

@class YummyMetroViewData,YummyMetroView;

@protocol YummyMetroViewDataSource;
//********************************************************************************
// this is the real definition of YummyMetroViewDelegate
//********************************************************************************
@protocol YummyMetroViewDelegate <NSObject, UIScrollViewDelegate>
@optional

// Display customization

- (void) gridView: (YummyMetroView *) gridView willDisplayCell: (YummyCell *) cell forItemAtIndex: (NSUInteger) index;

// Selection

// Called before selection occurs. Return a new index, or NSNotFound, to change the proposed selection.
- (NSUInteger) gridView: (YummyMetroView *) gridView willSelectItemAtIndex: (NSUInteger) index;
- (NSUInteger) gridView: (YummyMetroView *) gridView willSelectItemAtIndex: (NSUInteger) index numFingersTouch:(NSUInteger) numFingers;
- (NSUInteger) gridView: (YummyMetroView *) gridView willDeselectItemAtIndex: (NSUInteger) index;
// Called after the user changes the selection
- (void) gridView: (YummyMetroView *) gridView didSelectItemAtIndex: (NSUInteger) index;
- (void) gridView: (YummyMetroView *) gridView didSelectItemAtIndex: (NSUInteger) index numFingersTouch:(NSUInteger)numFingers;
- (void) gridView: (YummyMetroView *) gridView didDeselectItemAtIndex: (NSUInteger) index;

// Called after animated updates finished
- (void) gridViewDidEndUpdateAnimation:(YummyMetroView *) gridView;

// NOT YET IMPLEMENTED
- (void) gridView: (YummyMetroView *) gridView gestureRecognizer: (UIGestureRecognizer *) recognizer activatedForItemAtIndex: (NSUInteger) index;

- (CGRect) gridView: (YummyMetroView *) gridView adjustCellFrame: (CGRect) cellFrame withinGridCellFrame: (CGRect) gridCellFrame;

// Editing
- (void)gridView:(YummyMetroView *)aGridView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndex:(NSUInteger)index;
@end


//********************************************************************************
// this is the real definition of YummyMetroView
//********************************************************************************
@interface YummyMetroView : UIScrollView
{
    id<YummyMetroViewDataSource> __unsafe_unretained   _dataSource;
    YummyMetroViewData *				_viewData;
    NSMutableDictionary *                              _reusableYummyCells;
    NSMutableArray *                                   _visibleCells;
    CGPoint                                            _touchBeganPosition;
    NSIndexSet *					_animatingIndices;
    NSRange							_visibleIndexRange;
    NSInteger						_reloadingSuspendedCount;
    NSUInteger						_selectedIndex;
	NSUInteger						_pendingSelectionIndex;
}

@property (nonatomic, retain) YummyMetroViewData * viewData;
@property (nonatomic, copy) NSIndexSet * animatingIndices;
@property (nonatomic, unsafe_unretained) IBOutlet id<YummyMetroViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) IBOutlet id<YummyMetroViewDelegate> delegate;

- (YummyCell *) dequeueReusableCellWithIdentifier: (NSString *) reuseIdentifier;
- (void) reloadData;
@end

//********************************************************************************
// this is the real definition of YummyMetroViewDataSource
//********************************************************************************
@protocol YummyMetroViewDataSource<NSObject>
@required
// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (NSUInteger) numberOfItemsInGridView: (YummyMetroView *) gridView;

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (YummyCell *) gridView: (YummyMetroView *) gridView cellForItemAtIndex: (NSUInteger) index;
-(void) setViewer:(YummyMetroView *) view;

@optional
// all cells are placed in a logical 'grid cell', all of which are the same size. The default size is 96x128 (portrait).
// The width/height values returned by this function will be rounded UP to the nearest denominator of the screen width.
// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (CGSize) portraitGridCellSizeForGridView: (YummyMetroView *) gridView;
@end