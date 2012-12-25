//
//  YummyItem.h
//  Yummy OnMe
//
//  Created by ttron on 2/11/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

typedef enum 
{
	category,
	food,
	restaurant
} YummyItemType;

@interface YummyItem : NSManagedObject
{
    //NSString * uid;
    //NSString * title;
    //NSString * imageURLString;
    //NSString * bgColorString;
    YummyItemType tpype;
}

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) NSString *bgColorString;
@property (nonatomic) YummyItemType type;


-(void)setTypeString:(NSString*) typeString;
@end