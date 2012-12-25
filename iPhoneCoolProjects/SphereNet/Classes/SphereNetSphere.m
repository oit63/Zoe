//
//  SphereNetSphere.m
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "SphereNetSphere.h"

#import <QuartzCore/QuartzCore.h>


@implementation SphereNetSphere

static const CGFloat kSphereSize = 40;

- (id)init
{
	if((self = [super init]))
	{
		_layer = [[CALayer alloc] init];
		[_layer setDelegate:self];
		[_layer setBounds:CGRectMake(0, 0, kSphereSize, kSphereSize)];
		[_layer setNeedsDisplay];
	}
	return self;
}

- (void)dealloc
{
	[_layer release];
	
	[super dealloc];
}

- (void)setColorR:(float)r g:(float)g b:(float)b
{
	if(r != _r || g != _g || b != _b)
	{
		_r = r;
		_g = g;
		_b = b;
		
		[_layer setNeedsDisplay];
	}
}

- (float)r
{
	return _r;
}

- (float)g
{
	return _g;
}

- (float)b
{
	return _b;
}

- (void)setPosition:(CGPoint)p
{
	[_layer setPosition:p];
	_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
}

- (CGPoint)position
{
	return [_layer position];
}

- (CALayer *)layer
{
	return _layer;
}

- (NSTimeInterval)lastUpdate
{
	return _lastUpdate;
}

static const CGFloat kSphereCenterOffset = 10;

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { _r, _g, _b, 1.0,
	                          _r, _g, _b, 0.7 };
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
	
	CGPoint offsetCenter = CGPointMake(kSphereSize / 2 - kSphereCenterOffset, kSphereSize / 2 - kSphereCenterOffset);
	CGPoint center = CGPointMake(kSphereSize / 2, kSphereSize / 2);
	CGContextDrawRadialGradient(ctx, gradient, offsetCenter, 0, center, kSphereSize / 2, 0);
	
	CFRelease(gradient);
	CFRelease(colorspace);
}

@end
