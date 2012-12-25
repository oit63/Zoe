//
//  cc_tsstAppDelegate.h
//  newinterfacebuilder
//
//  Created by ttron on 12/24/11.
//  Copyright (c) 2011年 Tsst Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webimageAppDelegate : NSObject <UIApplicationDelegate>
{
    IBOutlet UIWindow *window;
    IBOutlet UIWebView *myWebView;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIWebView *myWebView;

@end
