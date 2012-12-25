//
//  CustomImagePickerViewController.m
//  CustomImagePicker
//
//  Created by Ray Wenderlich on 1/27/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import "CustomImagePickerViewController.h"
#import "CustomImagePicker.h"
#import "CustomImagePickerAppDelegate.h"

@implementation CustomImagePickerViewController

@synthesize imageView = _imageView;
@synthesize imagePicker = _imagePicker;

- (void)viewDidLoad {

	// Initialize image picker
	_imagePicker = [[CustomImagePicker alloc] init];
	_imagePicker.title = @"Choose Custom Image";
	
	// Add images to the picker
	// Note that this can take time due to resizing for thumbnails, so for production you
	// should either: a) have full-size and thumbs for each image pre-made, or:
	//                b) put a loading indicator in as this code runs
	
	[_imagePicker addImage:[UIImage imageNamed:@"logo1.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo2.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo3.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo4.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo5.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo6.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo7.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo8.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo9.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo10.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo11.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo12.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo13.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo14.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo15.png"]];
	[_imagePicker addImage:[UIImage imageNamed:@"logo16.png"]];
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	_imageView.image = _imagePicker.selectedImage;
	
}

- (IBAction)chooseCustomImageTapped:(id)sender {

	CustomImagePickerAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *navController = [delegate navController];
    [navController pushViewController:_imagePicker animated:YES];
	
}

- (void)viewDidUnload {
    self.imageView = nil;
}

- (void)dealloc {
    [_imageView release];
	_imageView = nil;
    [_imagePicker release];
	_imagePicker = nil;
    [super dealloc];
}

@end
