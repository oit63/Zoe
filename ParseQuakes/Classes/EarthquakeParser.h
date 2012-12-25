//
//  EarthquakeParser.h
//  MapQuakes
//
//  Created by Bill Dudney on 6/19/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//
//  Licensed under the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0.html
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@class Earthquake;
@protocol EarthquakeParserDelegate;

// define a struct to hold the attribute info
struct _xmlSAX2Attributes 
{
  const xmlChar* localname;
  const xmlChar* prefix;
  const xmlChar* uri;
  const xmlChar* value;
  const xmlChar* end;
};
typedef struct _xmlSAX2Attributes xmlSAX2Attributes;

@interface EarthquakeParser : NSObject 
{
  Earthquake *_currentEarthquake;
  NSMutableString *_propertyValue;
  id<EarthquakeParserDelegate> _delegate;
  NSURLConnection *_connection;
  BOOL _done;
  BOOL _error;
  xmlParserCtxtPtr _xmlParserContext;
  NSOperationQueue *_retrieverQueue;
  
  BOOL _shouldUseLibXML;
  
  // libxml2 parsing stuff
  NSMutableString *_title;
  BOOL _parsingTitle;
  NSMutableString *_updated;
  BOOL _parsingUpdated;
  NSMutableString *_point;
  BOOL _parsingPoint;
}

+ (id)earthquakeParser;

@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, assign) BOOL error;
@property(nonatomic, assign) BOOL shouldUseLibXML;
@property(nonatomic, retain) Earthquake *currentEarthquake;
@property(nonatomic, retain) NSMutableString *propertyValue;
@property(nonatomic, assign) id<EarthquakeParserDelegate> delegate;
@property(nonatomic, retain) NSOperationQueue *retrieverQueue;

- (void)getEarthquakeData;

@end

@protocol EarthquakeParserDelegate <NSObject>

- (void)parser:(EarthquakeParser *)parser addEarthquake:(Earthquake *)earthquake;
- (void)parser:(EarthquakeParser *)parser encounteredError:(NSError *)error;
- (void)parserFinished:(EarthquakeParser *)parser;

@end