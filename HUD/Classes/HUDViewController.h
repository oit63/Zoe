//
//  HUDViewController.h
//  HUD
//
//  Created by Keith A Peters on 4/11/09.
//  Copyright BIT-101 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HUDViewController : UIViewController {
    UIImageView *selectedPod;
    UIView *hud;
    CGPoint dragOffset;
    BOOL hudIsDragging;
}

@property (nonatomic, retain) IBOutlet UIView *hud;

- (IBAction)moveLeft;
- (IBAction)moveRight;
- (IBAction)moveUp;
- (IBAction)moveDown;

@end

