//
//  Station.h
//

#import <Foundation/Foundation.h>

@interface Station : NSObject {
	NSString *stationId;
	NSString *name;
	float latitude;
	float longitude;
	float distance;
}

@property (copy) NSString *stationId;
@property (copy) NSString *name;
@property float latitude;
@property float longitude;
@property float distance;

@end
