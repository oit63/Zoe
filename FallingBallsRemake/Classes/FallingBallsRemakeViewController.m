//
//  FallingBallsRemakeViewController.m
//  FallingBallsRemake
//
//  Created by Keith A Peters on 4/5/09.
//  Copyright BIT-101 2009. All rights reserved.
//

#import "FallingBallsRemakeViewController.h"

@implementation FallingBallsRemakeViewController



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
    [super viewDidLoad];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
    stickman = [[UIImageView alloc]
                initWithFrame:CGRectMake(225, 270, 30, 30)];
    stickman.animationImages = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"run1.png"],
                                [UIImage imageNamed:@"run2.png"],
                                [UIImage imageNamed:@"run3.png"],
                                [UIImage imageNamed:@"run4.png"],
                                [UIImage imageNamed:@"run5.png"],
                                [UIImage imageNamed:@"run6.png"],
                                [UIImage imageNamed:@"run5.png"],
                                [UIImage imageNamed:@"run4.png"],
                                [UIImage imageNamed:@"run3.png"],
                                [UIImage imageNamed:@"run2.png"],
                                nil];
    stickman.animationDuration = 0.7;
    [stickman startAnimating];
    [self.view addSubview:stickman];
}

/*
 - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
	if(point.x < stickman.center.x)
	{
		stickman.transform = CGAffineTransformMakeScale(-1.0, 1.0);
	}
	else
	{
		stickman.transform = CGAffineTransformMakeScale(1.0, 1.0);
	}
    stickman.center = CGPointMake(point.x, 285);
}
*/

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if(acceleration.y > 0)
	{
		stickman.transform = CGAffineTransformMakeScale(-1.0, 1.0);
	}
	else
	{
		stickman.transform = CGAffineTransformMakeScale(1.0, 1.0);
	}
	double newX = stickman.center.x - acceleration.y * 30.0;
	if(newX < 10) newX = 10;
	if(newX > 470) newX = 470;
	stickman.center = CGPointMake(newX, stickman.center.y);
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[stickman release];
    [super dealloc]; 
}

@end
