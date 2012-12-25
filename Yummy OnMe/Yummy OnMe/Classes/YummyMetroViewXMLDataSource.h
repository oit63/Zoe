//
//  YummyMetroViewXMLDataSource.h
//  Yummy OnMe
//
//  Created by ttron on 2/10/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YummyMetroView.h"
#import "ParseOperation.h"

@interface YummyMetroViewXMLDataSource : NSObject<YummyMetroViewDataSource,ParseOperationDelegate>
{
    NSUInteger itemCount;
    NSURL * _url;
    BOOL isParsed;
    NSOperationQueue		*queue;
    NSURLConnection         *appListFeedConnection;
    NSMutableData           *appListData;
    NSMutableArray *yummyGroups;
    NSMutableArray *yummyItems;
    YummyMetroView *_view;
}

-(id)initFromUrl:(NSURL*) url;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableArray *yummyGroups;
@property (nonatomic, retain) NSMutableArray *yummyItems;
@property (nonatomic, retain) NSMutableData *appListData;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSURLConnection *appListFeedConnection;
@end
