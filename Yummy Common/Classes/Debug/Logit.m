//
//  Logit.m
//  Yummy
//
//  Created by ttron on 2/9/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "Logit.h"

@implementation Logit
void ShowIndexSet(NSString *name,NSIndexSet* iset)
{
    NSIndexSet * copy=[iset copy];
    unsigned index;
    NSMutableString *str=[[NSMutableString alloc]init];
    for (index=[copy firstIndex]; index!=NSNotFound; index=[copy indexGreaterThanIndex:index]) 
        [str appendString:[NSString stringWithFormat:@"%d,",index]];
    copy=nil;
    NSLog(@"%@[%@]",name,str);
}

void ShowRange(NSString *name,NSRange range)
{
    NSRange copy=NSMakeRange(range.location, range.length);
    unsigned index;
    NSMutableString *str=[[NSMutableString alloc]init];
    for (index=0; index<copy.length; index++) 
        [str appendString:[NSString stringWithFormat:@"%d,",(copy.location+index)]];
    NSLog(@"%@[%@]",name,str);
}

void ShowRect(NSString *name,CGRect rect)
{
    NSLog(@"%@(x:%f,y:%f,w:%f,h:%f)",name,rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
}
@end