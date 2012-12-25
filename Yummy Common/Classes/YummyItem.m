//
//  YummyItem.m
//  Yummy OnMe
//
//  Created by ttron on 2/11/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "YummyItem.h"
static NSString *kCategoty  = @"category";
static NSString *kFood  = @"food";
static NSString *kRestaurant  = @"restaurant";

@implementation YummyItem
@dynamic uid;
@dynamic title;
@dynamic imageURLString;
@dynamic bgColorString;
@synthesize type;

- (void)dealloc
{
    //[uid release];
    //[title release];
    //[imageURLString release];
    //[bgColorString release];
    [super dealloc];
}

-(id) init
{
    self.uid=@"";
    self.imageURLString=@"";
    [super init];
    return self;
}

-(void)setTypeString:(NSString *)typeString
{
    if([typeString hasPrefix:kCategoty])
        self.type=category;
    else if([typeString hasPrefix:kFood])
        self.type=food;
    else if([typeString hasPrefix:kRestaurant])
        self.type=restaurant;
}
@end