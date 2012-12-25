//
//  YummyCategoryCell.m
//  Yummy OnMe
//
//  Created by ttron on 2/9/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyCategoryCell.h"

@implementation YummyCategoryCell
@synthesize itemNum;
@synthesize categoryName;

-(void) layoutIcon:(CGRect)contentBounds
{
    CGSize cellSize=self.bounds.size;
    
    CGRect iconRect = CGRectInset( contentBounds, cellSize.width*0.15, cellSize.height*0.15 );//this a simple way
    CGSize contentSize=iconRect.size;
    CGSize iconSize=CGSizeZero;
    
    [self checkImage];  
    
    // scale it down to fit
    CGSize imageSize=_imageView.image.size;
    CGFloat hRatio = contentSize.width / imageSize.width;
    CGFloat vRatio = contentSize.height / imageSize.height;
    CGFloat ratio = MIN(hRatio, vRatio);
    
    iconSize.width =floorf(imageSize.width * ratio);
    iconSize.height = floorf(imageSize.height * ratio);
    
    _imageView.center=CGPointMake(128, 128);
    _imageView.bounds=CGRectMake(0, 0, iconSize.width, iconSize.height);
}

-(void) layoutLabels:(CGRect)contentBounds
{
    [_indexLabel setText:[NSString stringWithFormat:@"%d",_displayIndex]];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.backgroundColor = [UIColor clearColor]; 
    _indexLabel.font = [UIFont boldSystemFontOfSize: 30.0];
    CGRect frame00=CGRectMake(210, 0, 40, 40);
    _indexLabel.frame=frame00;
    
    
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor clearColor]; 
    _titleLabel.font = [UIFont boldSystemFontOfSize: 30.0];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    //_titleLabel.minimumFontSize = 16.0;
    
    
    CGRect bounds = CGRectMake(0, 210, 250, 40);//FIXME
    //NSLog(@"Label Bounds(%f,%f,%f,%f)",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);//XXX
    
    [_titleLabel setText:self.yummyItem.title];
    
    CGRect frame = _titleLabel.frame;
    frame.size.width = MIN(frame.size.width, bounds.size.width);
    frame.origin.y = CGRectGetMaxY(bounds) - frame.size.height;
    frame.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
    _titleLabel.frame = frame;
    _titleLabel.frame = bounds;
}

@end
