//
//  SphereNetViewController.h
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright Rogue Amoeba Software, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SphereNetNetworkController.h"


@class SphereNetNetworkController;
@class SphereNetSphere;
@interface SphereNetViewController : UIViewController <SphereNetNetworkControllerDelegate>
{
	SphereNetSphere *_localSphere;
	
	SphereNetNetworkController *_netController;
	NSMutableDictionary *_remoteSpheres;
	
	NSTimer *_idleRemovalTimer;
}

@end

