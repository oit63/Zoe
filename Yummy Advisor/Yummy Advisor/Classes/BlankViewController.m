#import "BlankViewController.h"

@implementation BlankViewController
@synthesize detailItem;
@synthesize navigationBar;




#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [[[self navigationBar] topItem] setTitle:@"Welcome to the Yummy Advisor!"];
    [super viewDidLoad];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (void)viewDidUnload 
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
    [detailItem release];
    [super dealloc];
}


- (void)showNavigationButton:(UIBarButtonItem *)button
{
    [[[self navigationBar] topItem] setLeftBarButtonItem:button animated:NO];
}

- (void)hideNavigationButton:(UIBarButtonItem *)button
{
    [[[self navigationBar] topItem] setLeftBarButtonItem:nil animated:NO];
}
@end