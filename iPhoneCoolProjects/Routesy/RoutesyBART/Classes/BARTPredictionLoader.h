//
//  BARTPredictionLoader.h
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@protocol BARTPredictionLoaderDelegate
- (void)xmlDidFinishLoading;
@end

@interface BARTPredictionLoader : NSObject {
	id _delegate;
	NSMutableData *predictionXMLData;
	NSMutableData *lastLoadedPredictionXMLData;
}

+ (BARTPredictionLoader*)sharedBARTPredictionLoader;
- (void)loadPredictionXML:(id<BARTPredictionLoaderDelegate>)delegate;
- (NSArray*)predictionsForStation:(NSString*)stationId;

@property (nonatomic,retain) NSMutableData *predictionXMLData;
@property (nonatomic,retain) NSMutableData *lastLoadedPredictionXMLData;

@end
