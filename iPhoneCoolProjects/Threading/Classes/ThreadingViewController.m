

#import "ThreadingViewController.h"

@implementation ThreadingViewController
@synthesize totalCount;
@synthesize thread1Label;
@synthesize thread2Label;
@synthesize thread3Label;
@synthesize thread4Label;
@synthesize button1Title;
@synthesize button2Title;
@synthesize button3Title;
@synthesize button4Title;
@synthesize updatedByThread;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	button1On = FALSE;
	button2On = FALSE;
	button3On = FALSE;
	button4On = FALSE;
	countThread1 = 0;
	countThread2 = 0;
	countThread3 = 0;
	countThread4 = 0;
	myLock = [[NSLock alloc]init];
	[super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


-(IBAction)launchThread1:(id)sender
{
	
	if (!button1On)
	{
		button1On = TRUE;
		[button1Title setTitle:@"Kill Counting 1" forState:UIControlStateNormal];
		[self performSelectorInBackground:@selector(thread1) withObject:nil];
	}
	else
	{
		button1On = FALSE;
		[button1Title setTitle:@"Start Counting 1" forState:UIControlStateNormal];
		
		
	}
}



-(void)thread1
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];// we are responsible for the memory pool
	NSNumber *myNumber = [NSNumber numberWithInteger:1]; // the thread number for updating the display
	
	while(button1On)
	{		
		for (int x=0; x<10; x++) 
		{		
			[self performSelectorOnMainThread:@selector(displayThread1Counts:) //call the displayThread1Counts method
								   withObject:myNumber //can be used to to display thread number
								waitUntilDone:YES]; //wait until the method returns
			[NSThread sleepForTimeInterval:0.5]; //slow things down and sleep for 1/2 second
		}
		[self performSelectorOnMainThread:@selector(countThreadLoops:) //after 10 increments update the total count
							   withObject:myNumber //pass the thread number that did the updating
							waitUntilDone:NO]; //don't need to wait. We have a critical section
	}
	
	[apool release];
	
}




-(void)displayThread1Counts:(NSNumber*)threadNumber
{
	countThread1 += 1;
	[thread1Label setText:[NSString stringWithFormat:@"%i", countThread1]];
	
}



-(IBAction)launchThread2:(id)sender
{
	if (!button2On)
	{
		button2On = TRUE;
		[button2Title setTitle:@"Kill Counting 2" forState:UIControlStateNormal];
		[self performSelectorInBackground:@selector(thread2) withObject:nil];
	}
	else
	{
		button2On = FALSE;
		[button2Title setTitle:@"Start Counting 2" forState:UIControlStateNormal];
		
	}
}



-(void)thread2
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	NSNumber *myNumber = [NSNumber numberWithInteger:2];
	
	while(button2On)
	{		
		for (int x=0; x<10; x++) 
		{		
			[self performSelectorOnMainThread:@selector(displayThread2Counts:)
								   withObject:myNumber
								waitUntilDone:YES];
			[NSThread sleepForTimeInterval:.5];
		}
		[self performSelectorOnMainThread:@selector(countThreadLoops:)
							   withObject:myNumber
							waitUntilDone:NO];
	}
	
	[apool release];
	
}




-(void)displayThread2Counts:(NSNumber*)threadNumber
{
	countThread2 += 1;
	[thread2Label setText:[NSString stringWithFormat:@"%i", countThread2]];
	
}


-(IBAction)launchThread3:(id)sender
{
	if (!button3On)
	{
		button3On = TRUE;
		[button3Title setTitle:@"Kill Counting 3" forState:UIControlStateNormal];
		[self performSelectorInBackground:@selector(thread3) withObject:nil];
	}
	else
	{
		button3On = FALSE;
		[button3Title setTitle:@"Start Counting 3" forState:UIControlStateNormal];
		
	}
}



-(void)thread3
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	NSNumber *myNumber = [NSNumber numberWithInteger:3];
	
	while(button3On)
	{		
		for (int x=0; x<10; x++) 
		{		
			[self performSelectorOnMainThread:@selector(displayThread3Counts:)
								   withObject:myNumber
								waitUntilDone:YES];
			[NSThread sleepForTimeInterval:.5];
		}
		[self performSelectorOnMainThread:@selector(countThreadLoops:)
							   withObject:myNumber
							waitUntilDone:NO];
	}
	
	[apool release];
	
}





-(void)displayThread3Counts:(NSNumber*)threadNumber
{
	countThread3 += 1;
	[thread3Label setText:[NSString stringWithFormat:@"%i", countThread3]];
	
}


-(IBAction)launchThread4:(id)sender
{
	if (!button4On)
	{
		button4On = TRUE;
		[button4Title setTitle:@"Kill Counting 4" forState:UIControlStateNormal];
		[self performSelectorInBackground:@selector(thread4) withObject:nil];
	}
	else
	{
		button4On = FALSE;
		[button4Title setTitle:@"Start Counting 4" forState:UIControlStateNormal];
		
	}
}



-(void)thread4
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	NSNumber *myNumber = [NSNumber numberWithInteger:4];
	
	while(button4On)
	{		
		for (int x=0; x<10; x++) 
		{		
			[self performSelectorOnMainThread:@selector(displayThread4Counts:)
								   withObject:myNumber
								waitUntilDone:YES];
			[NSThread sleepForTimeInterval:.5];
		}
		[self performSelectorOnMainThread:@selector(countThreadLoops:)
							   withObject:myNumber
							waitUntilDone:NO];
	}
	
	[apool release];
	
}



-(void)displayThread4Counts:(NSNumber*)threadNumber
{
	countThread4 += 1;
	[thread4Label setText:[NSString stringWithFormat:@"%i", countThread4]];
	
}



-(void)countThreadLoops:(NSNumber*)threadNumber
{
	[myLock lock]; //mutex to protect critical section
	total += 10;
	[self.totalCount setText:[NSString stringWithFormat:@"%i", total]];
	[self.updatedByThread setText:[NSString stringWithFormat:@"Last updated by thread # %i",[threadNumber integerValue]]];
	[myLock unlock]; //make sure you perform unlock or you will create a deadlock condition
}

-(IBAction)KillAllThreads:(id)sender
{
	button1On = FALSE;
	button2On = FALSE;
	button3On = FALSE;
	button4On = FALSE;
	
	[button1Title setTitle:@"Start Counting 1" forState:UIControlStateNormal];
	[button2Title setTitle:@"Start Counting 2" forState:UIControlStateNormal];
	[button3Title setTitle:@"Start Counting 3" forState:UIControlStateNormal];
	[button4Title setTitle:@"Start Counting 4" forState:UIControlStateNormal];
}


- (void)dealloc {
	[totalCount release];
	[thread1Label release];
	[thread2Label release];
	[thread3Label release];
	[thread4Label release];
	[button1Title release];
	[button2Title release];
	[button3Title release];
	[button4Title release];
	[updatedByThread release];
	[myLock release];
    [super dealloc];
}

@end
