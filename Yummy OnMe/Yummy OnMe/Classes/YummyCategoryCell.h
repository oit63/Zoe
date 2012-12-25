//
//  YummyCategoryCell.h
//  Yummy OnMe
//
//  Created by ttron on 2/9/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyCell.h"

@interface YummyCategoryCell : YummyCell
{
    NSUInteger itemNum;
    NSString * categoryName;
}

@property (nonatomic, assign) NSUInteger itemNum;
@property (nonatomic, assign) NSString * categoryName;

@end
