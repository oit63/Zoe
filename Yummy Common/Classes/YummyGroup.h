//
//  YummyGroup.h
//  Yummy OnMe
//
//  Created by ttron on 2/11/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YummyItem.h"

@interface YummyGroup : NSManagedObject
{
    //NSString *groupName;
    //NSUInteger sid;
    //NSMutableArray * yummyItems;
    //NSString * bgColorString;
}

@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, retain) NSMutableArray *yummyItems;
@property (nonatomic) NSInteger sid;
@property (nonatomic, retain) NSString *bgColorString;

-(NSUInteger) numberOfItemsInGroup;
-(void)addYummItem:(YummyItem*) item;
-(YummyItem*) itemAtIndex:(NSUInteger) index;
@end
