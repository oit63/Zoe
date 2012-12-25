//
//  Logit.h
//  Yummy
//
//  Created by ttron on 2/9/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logit : NSObject
void ShowIndexSet(NSString * name,NSIndexSet* iset);
void ShowRange(NSString * name,NSRange range);
void ShowRect(NSString * name,CGRect rect);
@end
