//
//  SphereNetViewController.m
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright Rogue Amoeba Software, LLC 2009. All rights reserved.
//

#import "SphereNetViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "SphereNetSphere.h"


@implementation SphereNetViewController

- (void)dealloc
{
	[_localSphere release];
	[_netController release];
	[_remoteSpheres release];
	[_idleRemovalTimer release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if(!_localSphere)
	{
		_localSphere = [[SphereNetSphere alloc] init];
		CGSize size = [[self view] bounds].size;
		srandomdev();
		[_localSphere setColorR:(CGFloat)random()/0x7fffffff g:(CGFloat)random()/0x7fffffff b:(CGFloat)random()/0x7fffffff];
		[_localSphere setPosition:CGPointMake(size.width / 2, size.height / 2)];
		[[[self view] layer] addSublayer:[_localSphere layer]];
	}
	if(!_netController)
	{
		_netController = [[SphereNetNetworkController alloc] initWithDelegate:self];
		[_netController localSphereDidMove:_localSphere];
	}
	if(!_idleRemovalTimer)
	{
		_idleRemovalTimer = [[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(idleRemoval) userInfo:nil repeats:YES] retain];
	}
}

- (void)moveLocalSphereFromTouch:(UITouch *)touch
{
	if(touch)
	{
		[_localSphere setPosition:[touch locationInView:[self view]]];
		[_netController localSphereDidMove:_localSphere];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self moveLocalSphereFromTouch:[touches anyObject]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self moveLocalSphereFromTouch:[touches anyObject]];
}

- (void)networkController:(SphereNetNetworkController *)controller didReceiveUpdate:(SphereNetSphereUpdate)update fromAddress:(NSData *)address
{
	SphereNetSphere *sphere = [_remoteSpheres objectForKey:address];
	if(!sphere)
	{
		sphere = [[[SphereNetSphere alloc] init] autorelease];
		if(!_remoteSpheres)
			_remoteSpheres = [[NSMutableDictionary alloc] init];
		[_remoteSpheres setObject:sphere forKey:address];
		[[[self view] layer] addSublayer:[sphere layer]];
	}
	
	[sphere setColorR:update.r g:update.g b:update.b];
	[sphere setPosition:update.position];
}

- (void)idleRemoval
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSMutableArray *toRemove = [NSMutableArray array];
	for(NSData *address in _remoteSpheres)
	{
		SphereNetSphere *sphere = [_remoteSpheres objectForKey:address];
		if(now - [sphere lastUpdate] > 10)
		{
			[toRemove addObject:address];
			[[sphere layer] removeFromSuperlayer];
		}
	}
	[_remoteSpheres removeObjectsForKeys:toRemove];
}

@end
