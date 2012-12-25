//
//  SphereNetNetworkController.h
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct
{
	float r, g, b;
	CGPoint position;
} SphereNetSphereUpdate;

@class SphereNetSphere;
@protocol SphereNetNetworkControllerDelegate;

@interface SphereNetNetworkController : NSObject
{
	id <SphereNetNetworkControllerDelegate> _delegate;
	
	int _socket;
	
	NSNetService *_advertisingService;
	NSNetServiceBrowser *_browser;
	NSMutableSet *_services;
	
	SphereNetSphereUpdate _lastSentUpdate;
}

- (id)initWithDelegate:(id <SphereNetNetworkControllerDelegate>)delegate;
- (void)localSphereDidMove:(SphereNetSphere *)sphere;

@end

@protocol SphereNetNetworkControllerDelegate

- (void)networkController:(SphereNetNetworkController *)controller didReceiveUpdate:(SphereNetSphereUpdate)update fromAddress:(NSData *)address;

@end
