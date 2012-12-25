//
//  BackgroundView.m
//  Touching
//
//  Created by Canis Lupus
//  Copyright 2009 Wooji Juice. All rights reserved.
//

#import "BackgroundView.h"
#import "Constants.h"

@implementation BackgroundView


- (void)awakeFromNib
{
    // Load the background images, store them for later.
    backgrounds = [[NSMutableArray alloc] initWithObjects: 
        [UIImage imageNamed:@"woody.jpg"],
        [UIImage imageNamed:@"fawny.jpg"],
        [UIImage imageNamed:@"rocky.jpg"],
        nil
        ];
        
    // The images are 320x480 but the status bar takes up some of that real-
    // estate. Adjust our frame accordingly:
    CGPoint pt = self.center;
    pt.y -= [UIApplication sharedApplication].statusBarFrame.size.height/2;
    self.center = pt;
    
    // Make a view to display the first image, and add it:
    imageIndex = 0;
    image = [[UIImageView alloc] initWithImage: [backgrounds objectAtIndex: imageIndex]];
    image.bounds = self.bounds;
    [self addSubview: image];  
}


- (void)dealloc 
{
    // clean up
    [image release];
    [backgrounds release];
    [super dealloc];
}


- (void)switchImages:(int)delta
{
    // step through the images array in the appropriate direction, 
    // wrapping round:
    imageIndex = imageIndex+delta;
    if (imageIndex==[backgrounds count])
        imageIndex=0;
    else if (imageIndex<0)
        imageIndex = [backgrounds count]-1;
        
    // Animate the change. Disallow further swipes until the animation is 
    // complete, as overlapping the animations gives an ugly effect
    self.userInteractionEnabled = NO;
    
    // Standard Cocoa Tuch animation block, with a callback when it's complete.
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    // We use a caching transition: This effectively takes a screenshot of the
    // view before we make any changes, and another after we're done, and then
    // animates between the two shots:
    UIViewAnimationTransition transition = delta>0? UIViewAnimationTransitionCurlUp : UIViewAnimationTransitionCurlDown;
    [UIView setAnimationTransition:transition forView:image cache:YES];
    // (The change in question just being to switch background images)
    image.image = [backgrounds objectAtIndex: imageIndex];
    [UIView commitAnimations];
    
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    // Safe to re-enable now
    self.userInteractionEnabled = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // This view has multitouch disabled, so we simply grab the only touch:
    UITouch* touch = [touches anyObject];
    // All we want is the coordinates, for comparison later:
    origin = [touch locationInView:self];
    lastMove = touch.timestamp;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if (touch.timestamp-lastMove > 0.1f)
    {
        // If the finger pauses, then it's not a swipe. Unless the user starts
        // a new swipe from this new position; so let's just reset in this 
        // instance.
        origin = [touch locationInView:self];
    }
    lastMove = touch.timestamp;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Again, just the one touch to care about in this example:
    UITouch* touch = [touches anyObject];
    CGPoint position = [touch locationInView:self];
    
    // We're going to assume a swipe if:
    // - the finger moved far enough vertically
    // - it didn't move too far horizontally
    // - it was still moving when it was lifted off the screen
    
    // We only care about distance, not direction, here:
    float deltaX = fabsf(position.x - origin.x); 
    if (deltaX>(SWIPE_VERTICAL_THRESHOLD*2)) 
        return; // too much sideways movement
    
    // How long ago was the last movement? If it was more than 1/10th second,
    // the user stopped moving while still touching the screen: it's a drag, 
    // not a swipe/flick:
    if (event.timestamp-touch.timestamp > SWIPE_PAUSE_THRESHOLD) 
        return;
        
    // did they swipe enough distance to trigger a change, and which way?
    float deltaY = position.y - origin.y;
    if (deltaY>SWIPE_VERTICAL_THRESHOLD)
        [self switchImages: -1];
    else if (deltaY<-SWIPE_VERTICAL_THRESHOLD)
        [self switchImages: 1];
}

@end
