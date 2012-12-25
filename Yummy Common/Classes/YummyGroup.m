//
//  YummyGroup.m
//  Yummy OnMe
//
//  Created by ttron on 2/11/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyGroup.h"

@implementation YummyGroup
@dynamic groupName;
@dynamic sid;
@dynamic yummyItems;
@dynamic bgColorString;

- (void)dealloc
{
    //[groupName release];
    //[yummyItems release];
    //[bgColorString release];
    [super dealloc];
}

-(NSUInteger) numberOfItemsInGroup
{
    if(self.yummyItems==nil)
        return 0;
    return [self.yummyItems count];
}

-(void)addYummItem:(YummyItem *)item
{
    if(self.yummyItems==nil)
        self.yummyItems=[[NSMutableArray alloc]init];
    [self.yummyItems addObject:item];
}

-(YummyItem*) itemAtIndex:(NSUInteger)index
{
    if (self.yummyItems) 
    {
        return [self.yummyItems objectAtIndex:index];
    }
    return nil;
}
@end