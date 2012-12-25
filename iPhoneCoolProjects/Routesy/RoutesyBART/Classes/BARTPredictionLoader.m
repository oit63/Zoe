//
//  BARTPredictionLoader.m
//

#import "BARTPredictionLoader.h"
#import "XPathQuery.h"
#import "Prediction.h"

@implementation BARTPredictionLoader
@synthesize predictionXMLData,lastLoadedPredictionXMLData;

- (void)loadPredictionXML:(id<BARTPredictionLoaderDelegate>)delegate {
	_delegate = delegate;
	
	// Load the predictions XML from BART's website
	// Make sure that bart.gov is reachable using the current connection
	
	SCNetworkReachabilityFlags  flags;
    SCNetworkReachabilityRef reachability =  SCNetworkReachabilityCreateWithName(NULL, [@"www.bart.gov" UTF8String]);
    SCNetworkReachabilityGetFlags(reachability, &flags);
	
	// The reachability flags are a bitwise set of flags that contain the information about
	// connection availability
	BOOL reachable = ! (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	
	NSURLConnection *conn;
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.bart.gov/dev/eta/bart_eta.xml"]];
	if ([NSURLConnection canHandleRequest:request] && reachable) {
		conn = [NSURLConnection connectionWithRequest:request delegate:self];
		if (conn) {
			self.predictionXMLData = [NSMutableData data];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// didReceiveResponse is called at the beginning of the request when
	// the connection is ready to receive data. We set the length to zero to
	// prepare the array to receive data
	[self.predictionXMLData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// Each time we receive a chunk of data, we'll appeend it to the 
	// data array.
	[self.predictionXMLData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// When the data has all finished loading, we set a copy of the 
	// loaded data for us to access. This will allow us to not worry about whether
	// a load is already in progress when accessing the data.
	
	self.lastLoadedPredictionXMLData = [self.predictionXMLData copy];
	
	// Make sure the _delegate object actually has the xmlDidFinishLoading
	// method, and if it does, call it to notify the delegate that the
	// data has finished loading.
	if ([_delegate respondsToSelector:@selector(xmlDidFinishLoading)]) {
		[_delegate xmlDidFinishLoading];
	}
}

- (NSArray*)predictionsForStation:(NSString*)stationId {
	NSMutableArray *predictions = nil; 
	if (self.predictionXMLData) {
		NSString *xPathQuery = [NSString stringWithFormat:@"//station[abbr='%@']/eta", stationId];
		NSArray *nodes = PerformXMLXPathQuery(self.predictionXMLData, xPathQuery);
		predictions = [NSMutableArray arrayWithCapacity:[nodes count]];
		
		NSDictionary *node;
		NSDictionary *childNode;
		NSArray *children;
		
		Prediction *prediction;
		for (node in nodes) {
			children = (NSArray*)[node objectForKey:@"nodeChildArray"];
			prediction = [[Prediction alloc] init];
			for (childNode in children) {
				[prediction	setValue:[childNode objectForKey:@"nodeContent"] forKey:[childNode objectForKey:@"nodeName"]];
			}
			if (prediction.destination && prediction.estimate) {
				[predictions addObject:prediction];
			}
			[prediction release];
		}
		
		NSLog(@"Predictions for %@: %@", stationId, predictions);
	}
	return predictions;
}

static BARTPredictionLoader *predictionLoader;

+ (BARTPredictionLoader*)sharedBARTPredictionLoader {
	
	@synchronized(self) {
		if (predictionLoader == nil) {
			[[self alloc] init];
		}
	}
    
	return predictionLoader;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    @synchronized(self) {
        if (predictionLoader == nil) {
            predictionLoader = [super allocWithZone:zone];
            return predictionLoader;  // assignment and return on first allocation
        }
    }
    
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}




@end
