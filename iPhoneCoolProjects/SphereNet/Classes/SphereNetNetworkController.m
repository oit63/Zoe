//
//  SphereNetNetworkController.m
//  SphereNet
//
//  Created by Michael Ash on 2/18/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "SphereNetNetworkController.h"

#import <netinet/in.h>
#import <sys/socket.h>

#import "SphereNetSphere.h"


@implementation SphereNetNetworkController

- (id)initWithDelegate:(id <SphereNetNetworkControllerDelegate>)delegate
{
	if((self = [self init]))
	{
		// assign the delegate
		_delegate = delegate;
		
		// set up the services container
		_services = [[NSMutableSet alloc] init];
		
		// set up the UDP socket
		_socket = socket(AF_INET, SOCK_DGRAM, 0);
		
		struct sockaddr_in addr;
		bzero(&addr, sizeof(addr));
		addr.sin_len = sizeof(addr);
		addr.sin_family = AF_INET;
		addr.sin_addr.s_addr = INADDR_ANY;
		
		addr.sin_port = htons(0);
		bind(_socket, (struct sockaddr *)&addr, sizeof(addr));
		
		socklen_t len = sizeof(addr);
		getsockname(_socket, (struct sockaddr *)&addr, &len);
		
		// advertise our newly created socket
		_advertisingService = [[NSNetService alloc] initWithDomain:@"local." type:@"_spherenet._udp." name:[[UIDevice currentDevice] uniqueIdentifier] port: ntohs(addr.sin_port)];
		[_advertisingService publish];
		
		// start looking for other services on the network
		_browser = [[NSNetServiceBrowser alloc] init];
		[_browser setDelegate:self];
		[_browser searchForServicesOfType:@"_spherenet._udp." inDomain:@""];
		
		// start the listener thread
		[NSThread detachNewThreadSelector:@selector(listenThread) toTarget:self withObject:nil];
	}
	return self;
}

- (void)dealloc
{
	[_advertisingService stop];
	[_browser stop];
	
	[_advertisingService release];
	[_browser release];
	
	[_services release];
	
	[super dealloc];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	if([[service name] isEqualToString:[[UIDevice currentDevice] uniqueIdentifier]])
		return;
	
	[service resolve];
	[_services addObject:service];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	[_services removeObject:service];
}

static const uint32_t kSphereNetPacketIdentifier = 'SpHn';
static const uint32_t kSphereNetPositionPacketType = 'posn';

#pragma pack(1)
typedef struct
{
	uint32_t identifier;
	uint32_t datatype;
} PacketHeader;

typedef struct
{
	PacketHeader header;
	int32_t x;
	int32_t y;
	uint8_t r;
	uint8_t g;
	uint8_t b;
} PositionPacket;
#pragma options align=reset

- (void)sendUpdates
{
	PositionPacket packet;
	packet.header.identifier = CFSwapInt32HostToBig(kSphereNetPacketIdentifier);
	packet.header.datatype = CFSwapInt32HostToBig(kSphereNetPositionPacketType);
	packet.r = round(_lastSentUpdate.r * 255.0);
	packet.g = round(_lastSentUpdate.g * 255.0);
	packet.b = round(_lastSentUpdate.b * 255.0);
	packet.x = CFSwapInt32HostToBig(round(_lastSentUpdate.position.x));
	packet.y = CFSwapInt32HostToBig(round(_lastSentUpdate.position.y));
	
	for(NSNetService *service in _services)
		for(NSData *address in [service addresses])
			sendto(_socket, &packet, sizeof(packet), 0, [address bytes], [address length]);
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
	[self performSelector:_cmd withObject:nil afterDelay:1.0];
}

- (void)localSphereDidMove:(SphereNetSphere *)sphere
{
	_lastSentUpdate.r = [sphere r];
	_lastSentUpdate.g = [sphere g];
	_lastSentUpdate.b = [sphere b];
	_lastSentUpdate.position = [sphere position];
	
	[self sendUpdates];
}

- (void)listenThread
{
	while(1)
	{
		PositionPacket packet;
		struct sockaddr addr;
		socklen_t socklen = sizeof(addr);
		ssize_t len = recvfrom(_socket, &packet, sizeof(packet), 0, &addr, &socklen);
		if(len != sizeof(packet))
			continue;
		
		if(CFSwapInt32BigToHost(packet.header.identifier) != kSphereNetPacketIdentifier)
			continue;
		if(CFSwapInt32BigToHost(packet.header.datatype) != kSphereNetPositionPacketType)
			continue;
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSData *packetData = [NSData dataWithBytes:&packet length:sizeof(packet)];
		NSData *addressData = [NSData dataWithBytes:&addr length:socklen];
		NSArray *arguments = [NSArray arrayWithObjects:packetData, addressData, nil];
		[self performSelectorOnMainThread:@selector(mainThreadReceivedPositionPacket:) withObject:arguments waitUntilDone:YES];
		[pool release];
	}
}

- (void)mainThreadReceivedPositionPacket:(NSArray *)arguments
{
	NSData *packetData = [arguments objectAtIndex:0];
	NSData *addressData = [arguments objectAtIndex:1];
	const PositionPacket *packet = [packetData bytes];
	SphereNetSphereUpdate update;
	
	update.r = (float)packet->r / 255.0;
	update.g = (float)packet->g / 255.0;
	update.b = (float)packet->b / 255.0;
	
	int32_t x = CFSwapInt32BigToHost(packet->x);
	int32_t y = CFSwapInt32BigToHost(packet->y);
	
	update.position = CGPointMake(x, y);
	
	[_delegate networkController:self didReceiveUpdate:update fromAddress:addressData];
}

@end
