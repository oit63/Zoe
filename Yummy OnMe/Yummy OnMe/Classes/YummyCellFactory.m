//
//  YummyCellFactory.m
//  Yummy OnMe
//
//  Created by ttron on 2/25/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyCellFactory.h"
#import "YummyCell.h"
#import "YummyCategoryCell.h"

@implementation YummyCellFactory
+YummyCell:(YummyItem*) yummyItem
{
    YummyItemType type=yummyItem.type;
    switch (type) 
    {
        case category:
            return [[YummyCategoryCell alloc ]initWithItem:yummyItem];
        case food:
            return [[YummyCell alloc ]initWithItem:yummyItem];
        default:
            break;
    }
    
    return nil;
}
@end
