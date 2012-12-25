//
//  YummyMetroViewDataSourceStatic.m
//  Yummy OnMe
//
//  Created by ttron on 2/10/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import "YummyMetroViewDataSourceStatic.h"
#import "YummyMetroView.h"
#import "UIImageExtras.h"

@implementation YummyMetroViewDataSourceStatic


- (id) init 
{
	if ((self = [super init])) 
    {
        NSArray * paths = [NSBundle pathsForResourcesOfType: @"jpg" inDirectory: [[NSBundle mainBundle] bundlePath]];
        NSMutableArray * allImageNames = [[NSMutableArray alloc] init];
        
        for ( NSString * path in paths )
        {
            
            [allImageNames addObject: [path lastPathComponent]];
        }
        
        // sort alphabetically
        _imageNames = [[allImageNames sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)] copy];
        
        return self;
    }
    return nil;
}

- (id) initWithArray:(NSArray*) array
{
    _imageNames=[array copy];
    return self;
}

#pragma mark -
#pragma mark Grid View Data Source

-(void) setViewer:(YummyMetroView *)view
{
    _view=view;
}

- (NSUInteger) numberOfItemsInGridView: (YummyMetroView *) aGridView
{
    return ( [_imageNames count] );
}

- (YummyCell *) gridView: (YummyMetroView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    //    static NSString * FilledCellIdentifier = @"FilledCellIdentifier";
    //static NSString * OffsetCellIdentifier = @"OffsetCellIdentifier";
    
    YummyCell * cell = (YummyCell *)[aGridView dequeueReusableCellWithIdentifier:PlainCellIdentifier];
    if ( cell == nil )
    {
        cell = [[YummyCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 256, 256)
                                reuseIdentifier: PlainCellIdentifier];
    }
    
    UIImage *img=[UIImage imageNamed: [_imageNames objectAtIndex: index]];
    cell.image = [img imageByScalingAndCroppingForSize:CGSizeMake(240, 240)];
    //    cell.title = [[_imageNames objectAtIndex: index] stringByDeletingPathExtension];
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (YummyMetroView *) aGridView
{
    return ( CGSizeMake(256, 256) );
}
@end
