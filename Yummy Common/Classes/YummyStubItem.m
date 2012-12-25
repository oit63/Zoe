//
//  YummyStubItem.m
//  Yummy OnMe
//
//  Created by ttron on 2/17/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyStubItem.h"

@implementation YummyStubItem
@synthesize bgColorString;
-(id) initWithBgColor:(NSString*) _bgColorString
{
    [super init];
    self.bgColorString=_bgColorString;
    return self;
}
@end