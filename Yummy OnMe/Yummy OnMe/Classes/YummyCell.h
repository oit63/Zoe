//
//  CategoryBox.h
//  Yummy
//
//  Created by ttron on 1/25/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YummyItem.h"
#import "ASIHTTPRequestDelegate.h"

@interface YummyCell : UIView<ASIHTTPRequestDelegate>
{
    YummyItem * _yummyItem;
    UILabel * _indexLabel;
    UILabel * _titleLabel;
    NSString * _uid;
    NSString *				_reuseIdentifier;
    UIImageView *           _imageView;
    UIView *				_contentView;
    UIView *				_backgroundView;
    //UIView *				_selectedBackgroundView;
    //UIView *				_selectedOverlayView;
    //UIColor *				_backgroundColor;
    UIColor *				_textColor;
    //NSTimer *				_fadeTimer;
    //CFMutableDictionaryRef	_selectionColorInfo;
    NSUInteger				_displayIndex;			// le sigh...
    CGFloat _padding;
    struct 
    {
        unsigned int separatorStyle:3;
        unsigned int selectionStyle:3;
        unsigned int separatorEdge:2;
        unsigned int animatingSelection:1;
        unsigned int backgroundColorSet:1;
        unsigned int usingDefaultSelectedBackgroundView:1;
        unsigned int selected:1;
        unsigned int highlighted:1;
        unsigned int becomingHighlighted:1;
        unsigned int setShadowPath:1;
        unsigned int editing:1;
        unsigned int hiddenForAnimation:1;
        unsigned int __RESERVED__:14;
    } _cellFlags;
}


@property (nonatomic, retain) YummyItem * yummyItem;
@property (nonatomic) CGFloat padding;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, copy) NSString * reuseIdentifier;
@property (nonatomic, readonly) NSString * uid;
@property (nonatomic, readonly, retain) UIView * contentView;
@property (nonatomic, assign) NSUInteger displayIndex;

- (id) initWithItem:(YummyItem *) yummyItem;
- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) reuseIdentifier;
- (void) setHighlighted: (BOOL) highlighted animated: (BOOL) animated;
- (void) touchAtPoint:(CGPoint) point;
- (void) prepareForReuse;
- (void) checkImage;
@end
