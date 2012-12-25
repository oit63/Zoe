//
//  Utilities.m
//  Touching
//
//  Created by Canis Lupus
//  Copyright 2009 Wooji Juice. All rights reserved.
//

CGSize CGPointDelta(CGPoint a, CGPoint b)
{
    return CGSizeMake(a.x-b.x, a.y-b.y);
}

CGPoint CGPointApplyDelta(CGPoint a, CGSize b)
{
    return CGPointMake(a.x+b.width, a.y+b.height);
}

CGSize CGSizeScale(CGSize size, float scale)
{
    return CGSizeMake(size.width*scale, size.height*scale);
}

float Interpolate(float a, float b, float i)
{
    return (b*i) + (a*(1.f-i));
}

