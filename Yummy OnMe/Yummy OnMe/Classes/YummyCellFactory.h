//
//  YummyCellFactory.h
//  Yummy OnMe
//
//  Created by ttron on 2/25/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YummyCell.h"
#import "YummyItem.h"

@interface YummyCellFactory : NSObject
+YummyCell:(YummyItem*) yummyItem;
@end
