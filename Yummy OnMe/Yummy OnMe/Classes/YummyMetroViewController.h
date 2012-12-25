//
//  YummyMetroViewController.h
//  Yummy
//
//  Created by ttron on 1/28/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YummyMetroView.h"
#import "ASIDownloadCache.h"

@interface YummyMetroViewController : UIViewController<YummyMetroViewDelegate>
{
    NSArray *_imageNames;
    id<YummyMetroViewDataSource>  _currentDataSource;
    //UIImage *selectedImage;
    //YummyMetroView * _metroView;
    NSMutableDictionary *imageDownloadsInProgress;
    
    ASIDownloadCache *_cache;
}
//@property (nonatomic, retain) NSArray *imageNames;
//@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) ASIDownloadCache *cache;
@end