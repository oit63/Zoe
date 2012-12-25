//
//  ControlFunZeroViewController.h
//  ControlFunZero
//
//  Created by ttron on 1/19/12.
//  Copyright (c) 2012年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSwitchesSegmentIndex    0

@interface ControlFunZeroViewController : UIViewController<UIActionSheetDelegate>
{
    
    UITextField    *nameField;
    UITextField    *numberField;
    UILabel        *sliderLabel;
    UISwitch       *leftSwitch;
    UISwitch       *rightSwitch;
    UIButton       *doSomethingButton;
}

@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *numberField;
@property (nonatomic, retain) IBOutlet UILabel *sliderLabel;
@property (nonatomic, retain) IBOutlet UISwitch *leftSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *rightSwitch;
@property (nonatomic, retain) IBOutlet UIButton *doSomethingButton;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)toggleControls:(id)sender;
- (IBAction)switchChanged:(id)sender;
- (IBAction)buttonPressed;
@end
