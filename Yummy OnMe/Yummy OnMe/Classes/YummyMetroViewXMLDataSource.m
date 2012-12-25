//
//  YummyMetroViewXMLDataSource.m
//  Yummy OnMe
//
//  Created by ttron on 2/10/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "YummyMetroViewXMLDataSource.h"
#import "YummyMetroView.h"
#import "YummyMetroViewData.h"
#import "UIImageExtras.h"
#import "YummyStubItem.h"
#import "YummyCellFactory.h"


@implementation YummyMetroViewXMLDataSource

@synthesize url=_url;
@synthesize appListData,queue,appListFeedConnection,yummyGroups,yummyItems;
-(id)initFromUrl:(NSURL*) url
{
    self.yummyGroups=[NSMutableArray array];
    self.yummyItems=[NSMutableArray array];
    
    isParsed=false;
    self.url=url;
    
    //TODO
    return self;
}


-(void)dealloc
{
    [yummyGroups release];
    [yummyItems release];
    [super dealloc];
}


// -------------------------------------------------------------------------------
//	didFinishParsing:appList
// -------------------------------------------------------------------------------
- (void)didFinishParsing:(NSArray *)groups
{
    //[self performSelectorOnMainThread:@selector(handleLoadedApps:) withObject:appList waitUntilDone:NO];
    [self.yummyGroups addObjectsFromArray:groups];
        
    self.queue = nil;   // we are finished with the queue and our ParseOperation
    YummyMetroViewData *data=_view.viewData;
    NSUInteger numberOfItemsPerRow=[data numberOfItemsPerRow];
    itemCount=0;
    for (YummyGroup* group in yummyGroups)
    {
        NSArray *items=group.yummyItems;
        NSUInteger numberOfitemsInGroupWithStub=0;
        NSUInteger numberOfitemsInGroup=[items count];
        NSUInteger numberOfRowsInGroup=0;
        //NSLog(@"Group with sid:%d",group.sid);
        
        numberOfRowsInGroup=numberOfitemsInGroup/numberOfItemsPerRow;
        if(numberOfitemsInGroup%numberOfItemsPerRow!=0)
            numberOfRowsInGroup+=1;
        
        numberOfitemsInGroupWithStub=numberOfRowsInGroup*numberOfItemsPerRow;
        NSUInteger pos=0;
        for(YummyItem *item in items)
        {
            [yummyItems addObject:item];
            pos++;
            //NSLog(@"Item with src:%@",item.imageURLString);
        }
        
        //for (; pos<numberOfitemsInGroupWithStub; pos++) 
        //{
        //    [yummyItems addObject:[[YummyStubItem alloc]initWithBgColor:group.bgColorString]];
        //   NSLog(@"Stub Item with bg:%@",group.bgColorString);
        //}
        
        itemCount+=pos;//numberOfitemsInGroupWithStub;
    }

    //refresh the view
    [_view reloadData];
}

- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

// -------------------------------------------------------------------------------
//	handleError:error
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Top Paid Apps"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.appListData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [appListData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.appListFeedConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;   // release our connection
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
    // "ownership of appListData has been transferred to the parse operation and should no longer be
    // referenced in this thread.
    //
    ParseOperation *parser = [[ParseOperation alloc] initWithData:appListData delegate:self];
    
    [queue addOperation:parser]; // this will start the "ParseOperation"
    [parser release];
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.appListData = nil;
}


-(void)fetchFromServer
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:_url];
    self.appListFeedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    NSAssert(self.appListFeedConnection != nil, @"Failure to create URL connection.");
}

// The following are delegate methods for YummyMetroViewDataSource.

-(void) setViewer:(YummyMetroView *)view
{
    _view=view;
}

- (NSUInteger) numberOfItemsInGridView: (YummyMetroView *) aGridView
{
    if(!isParsed)
    {
        [self fetchFromServer];
    }
    
    NSLog(@"Total Item Count:%d",itemCount);
    return itemCount;
}

- (YummyCell *) gridView: (YummyMetroView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    NSLog(@"cellForItemAtIndex:%d",index);
    
    //static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    YummyCell * cell = nil;//(YummyCell *)[aGridView dequeueReusableCellWithIdentifier:PlainCellIdentifier];
    
    CGSize cellSize=[_view.viewData cellSize];
    if ( cell == nil )
    {
        //cell = [[YummyCell alloc] initWithFrame: CGRectMake(0.0, 0.0, cellSize.width, cellSize.height)
        //                        reuseIdentifier: PlainCellIdentifier];
        //[cell setYummyItem:[yummyItems objectAtIndex:index]]; 
        cell=[YummyCellFactory YummyCell:[yummyItems objectAtIndex:index]];
        [cell setFrame:CGRectMake(0.0, 0.0, cellSize.width, cellSize.height)];
    }
    
    
    
    //UIImage *img=[UIImage imageNamed: [_imageNames objectAtIndex: index]];
    //cell.image = [img imageByScalingAndCroppingForSize:CGSizeMake(240, 240)];
    //    cell.title = [[_imageNames objectAtIndex: index] stringByDeletingPathExtension];
    return ( cell );
}
@end