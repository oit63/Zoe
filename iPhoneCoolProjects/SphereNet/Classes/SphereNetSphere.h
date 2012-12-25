//
//  SphereNetSphere.h
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SphereNetSphere : NSObject
{
	float _r, _g, _b;
	CALayer *_layer;
	NSTimeInterval _lastUpdate;
}

- (void)setColorR:(float)r g:(float)g b:(float)b;
- (float)r;
- (float)g;
- (float)b;
- (void)setPosition:(CGPoint)p;
- (CGPoint)position;
- (CALayer *)layer;
- (NSTimeInterval)lastUpdate;

@end
