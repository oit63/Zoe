//
//  GadgetView.m
//  Touching
//
//  Created by Canis Lupus
//  Copyright 2009 Wooji Juice. All rights reserved.
//

#import "GadgetView.h"
#import "Constants.h"
#import "Utilities.h"

@interface GadgetView (Private)
- (void) stopTimer; // forward declaration
@end

@implementation GadgetView


//----------------------------------------------------------------------------
#pragma mark Initialisation/destruction

- (void)awakeFromNib
{
    timer = nil;
    modeLock = lockNotYetChosen;

    // so we can reset to it later:
    defaultSize = self.bounds.size.width;
    
    // In Interface Builder, I set one of the gadgets' tags as a flag to
    // indicate it should use the 'modal' behaviour:
    modal = self.tag;
}


- (void)dealloc 
{
    [self stopTimer];
    [super dealloc];
}


//----------------------------------------------------------------------------
#pragma mark Background animation processing

- (void) startTimer
{
    if (!timer)
    {
        // 60fps -- the fastest the iPhone will redraw the screen at anyway
        timer = [[NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES] retain];
    }
}


- (void) stopTimer
{
    [timer invalidate];
    [timer release];
    timer = nil;
}


- (void) check:(CGPoint*)position delta:(CGSize*)delta halfSize:(CGSize)halfSize forBouncingAgainst:(CGSize)containerSize
{
    // Has a moving gadget hit the edge of the screen?
    // Note the damping -- bounces feel more realistic if you lose some 
    // energy in the impact.
    if ((position->x - halfSize.width)<0)
    {
        delta->width = fabsf(delta->width)*BOUNCE_DAMPING;
        position->x = halfSize.width;
    }
    if ((position->x + halfSize.width)>containerSize.width)
    {
        delta->width = fabsf(delta->width)*-BOUNCE_DAMPING;
        position->x = containerSize.width - halfSize.width;
    }
    if ((position->y - halfSize.height)<0)
    {
        delta->height = fabsf(delta->height)*BOUNCE_DAMPING;
        position->y = halfSize.height;
    }
    if ((position->y + halfSize.height)>containerSize.height)
    {
        delta->height = fabsf(delta->height)*-BOUNCE_DAMPING;
        position->y = containerSize.height - halfSize.height;
    }
}


- (void) timerTick: (NSTimer*)timer
{
    // Here's where we process the inertia: Moving gadgets keep moving until
    // friction or your finger brings them to a halt.
    
    // Apply friction to the motion vector:
    dragDelta = CGSizeScale(dragDelta, INERTIAL_DAMPING);
    
    // Have we come to a halt?
    if ((fabsf(dragDelta.width)>DELTA_ZERO_THRESHOLD) || (fabsf(dragDelta.height)>DELTA_ZERO_THRESHOLD))
    {
        // Still moving. Apply that motion...
        CGPoint ctr = CGPointApplyDelta(self.center, dragDelta);
        
        // And check the screen-edges -- let's have it bounce rather than fly
        // off the edge of the screen where you can't get it back.
        CGSize halfSize = CGSizeMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self check:&ctr delta:&dragDelta halfSize:halfSize forBouncingAgainst:self.superview.bounds.size];
        
        // Update the graphics to the new position
        self.center = ctr;
    }
    else
    {
        // Yes -- give the user's battery some love by stopping the timer:
        [self stopTimer];
    }
}


//----------------------------------------------------------------------------
#pragma mark Touch calculations

- (float) calculatePinch:(NSArray*)twoTouches
{
    NSParameterAssert([twoTouches count]==2);
    // Given two touches, figure out how far apart they are, by getting
    // their positions, subtracting the vectors, and applying Pythagorus
    CGPoint first  = [[twoTouches objectAtIndex:0] locationInView:self];
    CGPoint second = [[twoTouches objectAtIndex:1] locationInView:self];
    CGSize  delta  = CGPointDelta(first, second);
    return sqrt(delta.width*delta.width + delta.height*delta.height);
}


- (float) calculateAngle:(NSArray*)twoTouches
{
    NSParameterAssert([twoTouches count]==2);
    // Given two touches, find the angle of the line between them. Mostly
    // the same as calculatePinch but uses atan2f to get the angle. But,
    // although it's highly likely they'll stay constant, we can't guarantee 
    // the order of the touches and if they swap, the angle would flip 180.
    UITouch* firstTouch = [twoTouches objectAtIndex:0];
    UITouch* secondTouch = [twoTouches objectAtIndex:1];
    // Their pointers remain the same tho, so we can compare & switch them:
    if (firstTouch>secondTouch)
    {
        UITouch* temp = firstTouch;
        firstTouch = secondTouch;
        secondTouch = temp;
    }
    CGPoint first  = [firstTouch locationInView:self.superview];
    CGPoint second = [secondTouch locationInView:self.superview];
    CGSize  delta  = CGPointDelta(first, second);
    return atan2f(delta.height, delta.width);
}


- (CGPoint) averageTouchPoint:(NSArray*)touches
{
    // Given any list of touches, find the average of their locations
    // (eg the midpoint between two fingers)
    CGPoint result = CGPointMake(0.f, 0.f);
    if ([touches count])
    {
        for (UITouch* touch in touches)
        {
            CGPoint point = [touch locationInView:self.superview];
            result.x += point.x;
            result.y += point.y;
        }
        result.x /= [touches count];
        result.y /= [touches count];
    }
    return result;
}


//----------------------------------------------------------------------------
#pragma mark Input Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // The important thing, is to find all touches that concern this gadget
    // (and only this gadget). The total number, affects our interpretation:
    NSSet* allTouches = [event touchesForView:self];
    if ([allTouches count]>2)
    {
        // We don't process any three-finger gestures.
    }
    else if ([allTouches count]==2)
    {
        // Let's put those calculations to use and store their initial values
        // so we can commpare against them later
        NSArray* twoTouches = [allTouches allObjects];
        lastPinch = [self calculatePinch:twoTouches];
        lastRotation = [self calculateAngle:twoTouches];
        lastCenter = [self averageTouchPoint:twoTouches];
        
        // By default, we'll assume a two-finger (axis-locked) drag, unless 
        // the touches start to move relative to each other.
        // Note that we test the modeLock to avoid getting crazy results near
        // the edge of the screen or other temporary loss-of-contact events
        if (modeLock==lockNotYetChosen)
        {
            axisLockedDrag = YES;
            originalCenter = lastCenter;
        }
    }
    else
    {
        // Nice, simple, single-finger touch. Nothing to do here except
        // check for a double-tap and reset the gadget's size if so.
        UITouch* touch = [allTouches anyObject];
        if (touch.tapCount==2)
        {
            CGPoint ctr = self.center;
            CGRect bounds = self.bounds;
            bounds.size.width = defaultSize;
            bounds.size.height = defaultSize;
            self.bounds = bounds;
            self.center = ctr;
        }        
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Same routine as before
    NSSet* allTouches = [event touchesForView:self];
    if ([allTouches count]==1)
    {
        // Just a single-finger gesture. But, if we've locked into a 2-finger
        // gesture already, then we must've lost one of the fingers -- 
        // probably off the edge of the screen. To avoid nasty jittering 
        // effects, lock out processing until they either put their second
        // finger back on, or release the screen entirely
        if (modeLock>lockNotYetChosen) return;
        
        // But if we're just dealing with a straight-forward single-finger
        // drag, it's easy: find the finger's movement...
        UITouch* anyTouch = [touches anyObject];
        lastMove = anyTouch.timestamp;
        CGPoint now  = [anyTouch locationInView: self.superview];
        CGPoint then = [anyTouch previousLocationInView: self.superview];
        dragDelta = CGPointDelta(now, then);

        // ...and apply the same movement to the gadget:
        self.center = CGPointApplyDelta(self.center, dragDelta);
        [self stopTimer];        
    }
    else if ([allTouches count]==2)
    {
        // Right, now we have our work cut out for us. Get all the
        // values we're likely to need:
        NSArray* twoTouches = [allTouches allObjects];
        float pinch = [self calculatePinch:twoTouches];
        float rotation = [self calculateAngle:twoTouches];
        CGPoint touchCenter = [self averageTouchPoint:twoTouches];
        CGSize delta = CGPointDelta(touchCenter, lastCenter);
        CGPoint gadgetCenter = self.center;
        
        if (axisLockedDrag && (modeLock==lockNotYetChosen))
        {
            // So far, we know we have a two-finger gesture but nothing else
            // is decided. We're assuming a two-finger (axis-locked) drag 
            // until we hear otherwise. But here's where we check for those
            // alternatives:
            if (fabsf(pinch-lastPinch)>PINCH_THRESHOLD)
            {
                // Perhaps the fingers got closer or further away?
                axisLockedDrag = NO;
                if (modal)
                    modeLock = lockToScale;
            }
            else if (fabsf(rotation-lastRotation)>ROTATION_THRESHOLD)
            {
                // Or rotated relative to each other?
                axisLockedDrag = NO;
                if (modal)
                    modeLock = lockToRotation;
            }
            else
            {
                // No, none of that. So we're still dragging. Since this is
                // an axis-locked drag, we want to figure out which axis to
                // lock into. Nobody's perfect, so we allow a bit of drift in
                // either axis, before locking down.
                CGSize dragDistance = CGPointDelta(touchCenter, originalCenter);
                if (fabsf(dragDistance.width)>AXIS_LOCK_THRESHOLD)
                {
                    modeLock = lockToXAxis;
                }
                else if (fabsf(dragDistance.height)>AXIS_LOCK_THRESHOLD)
                {
                    modeLock = lockToYAxis;
                }                
            }
        }
        
        // OK, after all that mode-detection, we actually need to process
        // whichever mode we're left in.
        if (axisLockedDrag)
        {
            // If we're doing an axis-locked drag, we just cancel out the
            // movement in the _other_ axis. We also pull the gadget back to
            // its original position on that axis, just in case there was any
            // drift. (You might instead prefer to simply not move the gadget
            // at all until it's dragged far enough on a particular axis. This
            // is slightly less responsive, but can give a pleasing 'magnetic'
            // feel to it.)
            switch(modeLock)
            {
            case lockToXAxis:
                delta.height = 0;
                gadgetCenter.y = Interpolate(gadgetCenter.y, originalCenter.y, 0.1f);
                break;
            case lockToYAxis:
                delta.width = 0;
                gadgetCenter.x = Interpolate(gadgetCenter.x, originalCenter.x, 0.1f);
                break;
            }
            self.center = CGPointApplyDelta(gadgetCenter, delta);
        }
        else
        {
            // We're doing something fancier, a rotation or scaling, or both.
            // Either way, we just apply the changes quite straightforwardly.
            if (modeLock!=lockToScale)
            {
                CGAffineTransform transform = self.transform;
                transform = CGAffineTransformRotate(transform, rotation-lastRotation);
                self.transform = transform;
            }
            if (modeLock!=lockToRotation)
            {
                float scale = pinch/lastPinch;
                CGRect bounds = self.bounds;
                bounds.size.width *= scale;
                bounds.size.height *= scale;
                self.bounds = bounds;
            }
            // For 'free-form' dragging, we also allow the gadget to move.
            if (modeLock==lockNotYetChosen)            
                self.center = CGPointApplyDelta(self.center, delta);

            lastPinch = pinch;
            lastRotation = rotation;
        }
        lastCenter = touchCenter;        
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // We're only interested in fingers leaving the screen if there are no
    // more fingers touching this view.
    NSSet* allTouches = [event touchesForView:self];
    if ([touches count]==[allTouches count])
    {
        // OK, all fingers are clear, so we can cancel the locks
        modeLock = lockNotYetChosen;
        
        // But we still need to figure out if that marked the end of a
        // drag or a flick. Check firstly if the finger stopped moving:
        if ((event.timestamp - lastMove) > MOVEMENT_PAUSE_THRESHOLD)
            return;
        // And secondly if it was only moving very, very slowly
        if ((fabsf(dragDelta.width)>INERTIA_THRESHOLD) || (fabsf(dragDelta.height)>INERTIA_THRESHOLD))
        {
            // It was still moving, and fast enough: start processing inertia
            [self startTimer];
        }
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // A system event interrupted us: hold everything
    modeLock = lockNotYetChosen;
    [self stopTimer];
}


@end
