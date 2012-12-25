//
//  Prediction.h
//

#import <Foundation/Foundation.h>

@interface Prediction : NSObject {
	NSString *destination;
	NSString *estimate;
}

@property (copy) NSString *destination;
@property (copy) NSString *estimate;

@end