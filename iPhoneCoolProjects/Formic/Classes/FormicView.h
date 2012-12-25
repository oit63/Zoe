//
//  FormicView.h
//  Formic
//
//  Created by Wolfgang Ante on 11.01.09.
//  Copyright 2009 ARTIS Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormicGame.h"

#define RADIUS		117.0
#define PI			3.141592653589793

@interface FormicView : UIView
{
	CGRect			mPieRect[GAME_CIRCLES];
	CGRect			mCenterRect;
	CGGradientRef	mGradient;
}

- (void)viewDidLoad;

- (CGPoint)centerForCircle:(int)circle;

@end
