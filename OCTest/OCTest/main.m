//
//  main.m
//  OCTest
//
//  Created by ttron on 2/9/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
    
    @autoreleasepool 
    {
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSMutableIndexSet *removedIndices=[[NSMutableIndexSet alloc]init];
        for(int i=1;i<7;i++)
            [removedIndices addIndex:i];
        
        [removedIndices addIndex:15];
        [removedIndices addIndex:19];
        [removedIndices addIndex:23];
        
        
        NSInteger index;
        NSMutableString *str=[[NSMutableString alloc]init];
        for (index=[removedIndices firstIndex]; index!=NSNotFound; index=[removedIndices indexGreaterThanIndex:index]) 
        {
            [str appendString:[NSString stringWithFormat:@"%d,",index]];
        }
        NSLog(@"newVisibleIndices[%@]",str);
        
        
        NSInteger startIndex=8;
        NSInteger delta=-15;
        NSMutableIndexSet * shifted = [removedIndices mutableCopy];
        [shifted shiftIndexesStartingAtIndex: startIndex by: delta];
        
        
        str=[[NSMutableString alloc]init];
        for (index=[shifted firstIndex]; index!=NSNotFound; index=[shifted indexGreaterThanIndex:index]) 
        {
            [str appendString:[NSString stringWithFormat:@"%d,",index]];
        }
        NSLog(@"shifted(startIndex:%lu,delta:%ld)[%@]",startIndex,delta,str);
        
        
        CGFloat f=5.6f;
        CGFloat ddd=roundf(f);
        NSLog(@"%f",ddd);
    }
    
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString * unid=(NSString *)CFUUIDCreateString(NULL, uuid);
    
    NSLog(@"%@",unid);
    
    return 0;
}
