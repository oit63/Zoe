//
//  GadgetView.h
//  Touching
//
//  Created by Canis Lupus
//  Copyright 2009 Wooji Juice. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum { lockNotYetChosen, lockToXAxis, lockToYAxis, lockToRotation, lockToScale  } ModeLock;

@interface GadgetView : UIImageView {
    NSTimer*        timer;
    float           defaultSize;
    CGSize          dragDelta;
    NSTimeInterval  lastMove;
    float           lastPinch;
    float           lastRotation;
    CGPoint         lastCenter;
    CGPoint         originalCenter;
    BOOL            axisLockedDrag;
    BOOL            modal;
    ModeLock        modeLock;
}
@end


