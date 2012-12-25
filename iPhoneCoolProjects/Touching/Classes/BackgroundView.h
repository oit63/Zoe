//
//  BackgroundView.h
//  Touching
//
//  Created by Canis Lupus
//  Copyright 2009 Wooji Juice. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BackgroundView : UIView {
    NSArray*        backgrounds;
    UIImageView*    image;
    int             imageIndex;
    CGPoint         origin;
    NSTimeInterval  lastMove;
}

@end
