//
//  YummyMetroViewDataSourceStatic.h
//  Yummy OnMe
//
//  Created by ttron on 2/10/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YummyMetroView.h"

@interface YummyMetroViewDataSourceStatic : NSObject<YummyMetroViewDataSource>
{
    NSArray *_imageNames;
    YummyMetroView *_view;
}

- (id) initWithArray: (NSArray*) imageNames;
@end