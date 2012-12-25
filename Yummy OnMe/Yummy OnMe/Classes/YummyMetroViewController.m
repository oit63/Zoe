//
//  YummyMetroViewController.m
//  Yummy
//
//  Created by ttron on 1/28/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "YummyMetroViewController.h"
#import "YummyMetroView.h"
#import "UIImageExtras.h"
#import "YummyMetroViewDataSourceStatic.h"
#import "YummyMetroViewXMLDataSource.h"


@implementation YummyMetroViewController

//static NSString *const YummyHomeUrl=@"http://218.22.178.126:8080/cc.tsst.onme.yummy/xml/home.xml";
static NSString *const YummyHomeUrl=@"http://218.22.178.126:1865/cc.tsst.onme.yummy/rest/groups";
//static NSString *const YummyHomeUrl=@"http://192.168.1.57/zoe/soft/soft__.xml";
//@synthesize metroView=_gridView;
@synthesize imageDownloadsInProgress;
@synthesize cache=_cache;

- (void)dealloc 
{
    [imageDownloadsInProgress release];
    [super dealloc];
}

- (id) init 
{
	if ((self = [super init])) 
    {
        self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
        //self.cache = [[ASIDownloadCache alloc] init];
        //[self.cache setStoragePath: NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        return self;
	}
	
    return nil;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{ 
    //_currentDataSource=[[YummyMetroViewDataSourceStatic alloc]init];
    _currentDataSource=[[YummyMetroViewXMLDataSource alloc] initFromUrl:[NSURL URLWithString:YummyHomeUrl]];
    
    
   
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillResignActive:)
												 name:UIApplicationWillResignActiveNotification
											   object:app];
}

- (void)applicationWillResignActive:(NSNotification *)notification 
{
    //TODO
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    YummyMetroView *view = [[YummyMetroView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = view;
	[view release];
    [(YummyMetroView *)self.view setDataSource:_currentDataSource];
    [(YummyMetroView *)self.view reloadData];
    [super viewDidLoad];
}

- (void) viewWillAppear: (BOOL) animated
{
	//if ( (_clearsSelectionOnViewWillAppear) && ([self.gridView indexOfSelectedItem] != NSNotFound) )
	//{
	//	[self.gridView deselectItemAtIndex: [self.gridView indexOfSelectedItem] animated: NO];
	//}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
@end