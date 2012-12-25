//
//  HUDViewController.m
//  HUD
//
//  Created by Keith A Peters on 4/11/09.
//  Copyright BIT-101 2009. All rights reserved.
//

#import "HUDViewController.h"

@implementation HUDViewController
@synthesize hud;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    hudIsDragging = NO;
    UITouch *touch = [touches anyObject];
    UIView *touchView = [touch view];
    if([touchView tag] == 1)
    {
        [UIView beginAnimations:nil context:nil];
        [hud setAlpha:1.0];
        [UIView commitAnimations];
        [selectedPod setAlpha:0.5];
        selectedPod = (UIImageView *)[touch view];
        [selectedPod setAlpha:1.0];
    }
    else if(touchView == hud)
    {
        hudIsDragging = YES;
        CGPoint touchPoint = [touch locationInView:self.view];
        dragOffset = CGPointMake(hud.center.x - touchPoint.x, hud.center.y - touchPoint.y);
                                 
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [hud setAlpha:0.0];
        [UIView commitAnimations];
        [selectedPod setAlpha:0.5];
        selectedPod = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    if(hudIsDragging)
    {
        [hud setCenter:CGPointMake(touchPoint.x + dragOffset.x, touchPoint.y + dragOffset.y)];
    }
    else
    {
        [selectedPod setCenter:touchPoint];
    }
}

- (void)moveLeft
{
    [selectedPod setCenter:CGPointMake(selectedPod.center.x - 1, selectedPod.center.y)];
}

- (void)moveRight
{
    [selectedPod setCenter:CGPointMake(selectedPod.center.x + 1, selectedPod.center.y)];
}

- (void)moveUp
{
    [selectedPod setCenter:CGPointMake(selectedPod.center.x, selectedPod.center.y - 1)];
}

- (void)moveDown
{
    [selectedPod setCenter:CGPointMake(selectedPod.center.x, selectedPod.center.y + 1)];
}

- (void)dealloc {
    [hud release];
    [super dealloc];
}

@end
