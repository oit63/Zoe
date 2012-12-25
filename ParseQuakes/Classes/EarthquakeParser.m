//
//  EarthquakeParser.m
//  MapQuakes
//
//  Created by Bill Dudney on 6/19/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//
//  Licensed under the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0.html
//

#import "EarthquakeParser.h"
#import "Earthquake.h"

// called from libxml functions
@interface EarthquakeParser (LibXMLParserMethods)

- (void)elementFound:(const xmlChar *)localname prefix:(const xmlChar *)prefix 
                 uri:(const xmlChar *)URI namespaceCount:(int)namespaceCount
          namespaces:(const xmlChar **)namespaces attributeCount:(int)attributeCount 
defaultAttributeCount:(int)defaultAttributeCount attributes:(xmlSAX2Attributes *)attributes;
- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI;
- (void)charactersFound:(const xmlChar *)characters length:(int)length;
- (void)parsingError:(const char *)msg, ...;
- (void)endDocument;

@end

// Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;

@implementation EarthquakeParser

@synthesize currentEarthquake = _currentEarthquake;
@synthesize propertyValue = _propertyValue;
@synthesize retrieverQueue = _retrieverQueue;
@synthesize delegate = _delegate;
@synthesize connection = _connection;
@synthesize error = _error;
@synthesize shouldUseLibXML = _shouldUseLibXML;

+ (id)earthquakeParser {
  // analyzer reports this as a potential leak
  // but self is released when the parsing is done
  // so it will be a leak if parsing never finishes
  // but if the parsing is finished then it won't be
	return [[[self class] alloc] init];
}

- (NSOperationQueue *)retrieverQueue {
	if(nil == _retrieverQueue) {
    // lazy creation of the queue for retrieving the earthquake data
		_retrieverQueue = [[NSOperationQueue alloc] init];
		_retrieverQueue.maxConcurrentOperationCount = 1;
	}
	return _retrieverQueue;
}

- (void)getEarthquakeData {
  // make an operation so we can push it into the queue
	SEL method = @selector(parseForData);
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self 
																	 selector:method 
																	   object:nil];
	[self.retrieverQueue addOperation:op];
	[op release];
}

static NSString *feedURLString = @"http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml";

- (BOOL)parseWithLibXML2Parser {
  BOOL success = NO;
  // create a connection
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
  NSURLConnection *con = [[NSURLConnection alloc] 
                          initWithRequest:request
                          delegate:self];
  self.connection = con;
  [con release];
  // This creates a context for "push" parsing in which chunks of data that are 
  // not "well balanced" can be passed to the context for streaming parsing. 
  // The handler structure defined above will be used for all the parsing. The
  // second argument, self, will be passed as user data to each of the SAX
  // handlers. The last three arguments are left blank to avoid creating a tree
  // in memory.
  _xmlParserContext = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
  if(self.connection != nil) {
    do {
      [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while (!_done && !self.error);
  }
  if(self.error) {
    NSLog(@"parsing error");
    [self.delegate parser:self encounteredError:nil];
  } else {
    success = YES;
  }
  return success;
}

- (BOOL)parseWithNSXMLParser {
  NSURL *url = [NSURL URLWithString:feedURLString];
  BOOL success = NO;
  NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
  [parser setDelegate:self];
  [parser setShouldProcessNamespaces:NO];
  [parser setShouldReportNamespacePrefixes:NO];
  [parser setShouldResolveExternalEntities:NO];
  success = [parser parse];
  NSError *parseError = [parser parserError];
  if (parseError) {
	  NSLog(@"parse error = %@", parseError);
  } else {
    success = YES;
  }
  [parser release];
  return success;
}  

// this method is fired by the operation created in
// getEarthquakeData so it is on an alternate thread
- (BOOL)parseForData {
  BOOL success = NO;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  if(self.shouldUseLibXML) {
    success = [self parseWithLibXML2Parser];
  } else {
    success = [self parseWithNSXMLParser];
  }
  [pool drain];
  return success;
}

#pragma mark Parsing Function Callback Methods

/*
 Sample entry
 <entry>
   <id>urn:earthquake-usgs-gov:us:2008rkbc</id>
   <title>M 5.8, Banda Sea</title>
   <updated>2008-04-29T19:10:01Z</updated>
   <link rel="alternate" type="text/html" href="/eqcenter/recenteqsww/Quakes/us2008rkbc.php"/>
   <link rel="related" type="application/cap+xml" href="/eqcenter/catalogs/cap/us2008rkbc"/>
   <summary type="html">
     <img src="http://earthquake.usgs.gov/images/globes/-5_130.jpg" alt="6.102&#176;S 127.502&#176;E" align="left" hspace="20" /><p>Tuesday, April 29, 2008 19:10:01 UTC<br>Wednesday, April 30, 2008 04:10:01 AM at epicenter</p><p><strong>Depth</strong>: 395.20 km (245.57 mi)</p>
   </summary>
   <georss:point>-6.1020 127.5017</georss:point>
   <georss:elev>-395200</georss:elev>
   <category label="Age" term="Past hour"/>
 </entry>
 */

static const char *kEntryElementName = "entry";
static NSUInteger kEntryElementNameLength = 6;
static const char *kLinkElementName = "link";
static NSUInteger kLinkElementNameLength = 5;

static const char *kRelAttributeName = "rel";
static NSUInteger kRelAttributeNameLength = 4;
static const char *kHrefAttributeName = "href";
static NSUInteger kHrefAttributeNameLength = 5;

static const char *kTitleElementName = "title";
static NSUInteger kTitleElementNameLength = 6;
static const char *kUpdatedElementName = "updated";
static NSUInteger kUpdatedElementNameLength = 7;
static const char *kPointElementName = "point";
static NSUInteger kPointElementNameLength = 6;

static const char *kRelAlternateValueName = "alternate";
static NSUInteger kRelAlternateValueNameLength = 10;

- (void)elementFound:(const xmlChar *)localname prefix:(const xmlChar *)prefix 
                 uri:(const xmlChar *)URI namespaceCount:(int)namespaceCount
          namespaces:(const xmlChar **)namespaces attributeCount:(int)attributeCount 
defaultAttributeCount:(int)defaultAttributeCount attributes:(xmlSAX2Attributes *)attributes {
  if(0 == strncmp((const char *)localname, kEntryElementName, kEntryElementNameLength)) {
    self.currentEarthquake = [[[Earthquake alloc] init] autorelease];
  } else if(0 == strncmp((const char *)localname, kLinkElementName, kLinkElementNameLength)) {
    for(int i = 0;i < attributeCount;i++) {
      int valueLength = (int) (attributes[i].end - attributes[i].value);
      NSString *value = [[NSString alloc] initWithBytes:attributes[i].value
                                                 length:valueLength
                                               encoding:NSUTF8StringEncoding];
      // ignore the related content and just grab the alternate
      if(0 == strncmp((const char*)attributes[i].localname, kRelAttributeName,
                      kRelAttributeNameLength)) {
        
        if(0 == strncmp((const char*)attributes[i].value, kRelAlternateValueName,
                        kRelAlternateValueNameLength)) {
          // now look for the href, once found break out of the inner loop
          // then we go back and look for the title, updated and georss:point
          for(int j = i+1; j < attributeCount; j++) {
            if(0 == strncmp((const char*)attributes[j].localname, kHrefAttributeName,
                            kHrefAttributeNameLength)) {
              int urlLength = (int) (attributes[j].end - attributes[j].value);
              NSString *url = [[NSString alloc] initWithBytes:attributes[j].value
                                                       length:urlLength
                                                     encoding:NSUTF8StringEncoding];
              self.currentEarthquake.detailsURL = 
              [NSString stringWithFormat:@"http://earthquake.usgs.gov/%@", url];
              [url release];
              break;
            }
          }
        } else {
          // we don't care about the related linke, only the alternate
          [value release];
          break;
        }
      }
      [value release];
    }
  } else if(0 == strncmp((const char *)localname, kTitleElementName, kTitleElementNameLength)) {
    _title = [[NSMutableString alloc] init];
    _parsingTitle = YES;
  } else if(0 == strncmp((const char *)localname, kUpdatedElementName, kUpdatedElementNameLength)) {
    _updated = [[NSMutableString alloc] init];
    _parsingUpdated = YES;
  } else if(0 == strncmp((const char *)localname, kPointElementName, kPointElementNameLength)) {
    // we really should be looking at the namespaces as well but the feed does
    // not have more than one so I'm ignoring it here
    _point = [[NSMutableString alloc] init];
    _parsingPoint = YES;
  }
}

- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI {
  if(0 == strncmp((const char *)localname, kTitleElementName, kTitleElementNameLength)) {
    //<title>M 5.8, Banda Sea</title>
    NSArray *components = [_title componentsSeparatedByString:@","];
    if(components.count > 1) {
      // strip the M
      NSString *magString = [[[components objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:1];
      NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
      self.currentEarthquake.magnitude = [formatter numberFromString:magString];
      self.currentEarthquake.place = [components objectAtIndex:1];
      [formatter release];
    }
    [_title release];
    _title = nil;
    _parsingTitle = NO;
  } else if(0 == strncmp((const char *)localname, kUpdatedElementName, kUpdatedElementNameLength)) {
    //<updated>2008-04-29T19:10:01Z</updated>
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    self.currentEarthquake.lastUpdate = [formatter dateFromString:_updated];
    [formatter release];
    [_updated release];
    _updated = nil;
    _parsingUpdated = NO;
  } else if(0 == strncmp((const char *)localname, kPointElementName, kPointElementNameLength)) {
    //<georss:point>-6.1020 127.5017</georss:point>
    NSArray *comp = [_point componentsSeparatedByString:@" "];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *latituide = [formatter numberFromString:[comp objectAtIndex:0]];
    NSNumber *longitude = [formatter numberFromString:[comp objectAtIndex:1]];
    [formatter release];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latituide.floatValue
                                                      longitude:longitude.floatValue];
    self.currentEarthquake.location = location;
    [location release];
    // we really should be looking at the namespaces as well but the feed does
    // not have more than one so I'm ignoring it here
    [_point release];
    _point = nil;
    _parsingPoint = YES;
  } else if(0 == strncmp((const char *)localname, kEntryElementName, kEntryElementNameLength)) {
    SEL selector = @selector(parser:addEarthquake:);
    NSMethodSignature *sig = [(id)self.delegate methodSignatureForSelector:selector];
    if(nil != sig && [self.delegate respondsToSelector:selector]) {
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
      [invocation retainArguments];
      [invocation setTarget:self.delegate];
      [invocation setSelector:selector];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&_currentEarthquake atIndex:3];
      [invocation performSelectorOnMainThread:@selector(invoke) withObject:NULL waitUntilDone:NO];
    }
  }
}

- (void)charactersFound:(const xmlChar *)characters length:(int)length {
  if(_parsingTitle) {
    NSString *value = [[NSString alloc] initWithBytes:(const void *)characters
                                               length:length encoding:NSUTF8StringEncoding];
    [_title appendString:value];
    [value release];
  }
  if(_parsingUpdated) {
    NSString *value = [[NSString alloc] initWithBytes:(const void *)characters
                                               length:length encoding:NSUTF8StringEncoding];
    [_updated appendString:value];
    [value release];
  }
  if(_parsingPoint) {
    NSString *value = [[NSString alloc] initWithBytes:(const void *)characters
                                               length:length encoding:NSUTF8StringEncoding];
    [_point appendString:value];
    [value release];
  }
}

- (void)parsingError:(const char *)msg, ... {
  NSString *format = [[NSString alloc] initWithBytes:msg length:strlen(msg)
                                            encoding:NSUTF8StringEncoding];
  
  CFStringRef resultString = NULL;
  va_list argList;
  va_start(argList, msg);
  resultString = CFStringCreateWithFormatAndArguments(NULL, NULL,
                                                      (CFStringRef)format,
                                                      argList);
  va_end(argList);
  
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:(NSString*)resultString
                                                       forKey:@"error_message"];
  NSError *error = [NSError errorWithDomain:@"ParsingDomain"
                                       code:101
                                   userInfo:userInfo];

  SEL selector = @selector(parse:encounteredError:);
  NSMethodSignature *sig = [(id)self.delegate methodSignatureForSelector:selector];
  if(nil != sig && [self.delegate respondsToSelector:selector]) {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation retainArguments];
    [invocation setTarget:self.delegate];
    [invocation setSelector:selector];
    [invocation setArgument:&self atIndex:2];
    [invocation setArgument:&error atIndex:3];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:NULL waitUntilDone:NO];
  }

  [(NSString*)resultString release];
  [format release];
  _done = YES;
}

-(void)endDocument {
  [(id)[self delegate] performSelectorOnMainThread:@selector(parserFinished:)
                                        withObject:self
                                     waitUntilDone:NO];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [self autorelease];
}

#pragma mark NSURLConnection Delegate methods

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection 
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  // returning nil prevents the response from being cached
  return nil;
}

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error {
  SEL selector = @selector(parser:encounteredError:);
  NSMethodSignature *sig = [(id)self.delegate methodSignatureForSelector:selector];
  if(nil != sig && [self.delegate respondsToSelector:selector]) {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation retainArguments];
    [invocation setTarget:self.delegate];
    [invocation setSelector:selector];
    [invocation setArgument:&self atIndex:2];
    [invocation setArgument:&error atIndex:3];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:NULL waitUntilDone:NO];
  }
  _done = YES;
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)data {
  // Process the downloaded chunk of data.
  xmlParseChunk(_xmlParserContext, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  // Signal the context that parsing is complete by passing "1" as the last parameter.
  xmlParseChunk(_xmlParserContext, NULL, 0, 1);
  _done = YES;
}

#pragma mark NSXMLParser Methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  [(id)[self delegate] performSelectorOnMainThread:@selector(parserFinished:)
                                        withObject:self
                                     waitUntilDone:NO];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [self autorelease];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
  if(nil != qName) {
    elementName = qName; // swap for the qName if we have a name space
  }
  
  if ([elementName isEqualToString:@"entry"]) {
    self.currentEarthquake = [[[Earthquake alloc] init] autorelease];
  } else if([elementName isEqualToString:@"link"]) {
    // ignore the related content and just grab the alternate
    if ([[attributeDict valueForKey:@"rel"] isEqualToString:@"alternate"]) {
      NSString *link = [attributeDict valueForKey:@"href"];
      self.currentEarthquake.detailsURL = 
          [NSString stringWithFormat:@"http://earthquake.usgs.gov/%@", link];
    }
  } else if([elementName isEqualToString:@"title"] || 
            [elementName isEqualToString:@"updated"] ||
            [elementName isEqualToString:@"georss:point"]) {
    self.propertyValue = [NSMutableString string];
  } else {
    self.propertyValue = nil;
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if(nil != self.propertyValue) {
    [self.propertyValue appendString:string];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
  if (qName) {
    elementName = qName; // switch for the qName
  }
  
  if ([elementName isEqualToString:@"title"]) {
    //<title>M 5.8, Banda Sea</title>
    NSArray *components = [self.propertyValue componentsSeparatedByString:@","];
    if(components.count > 1) {
      // strip the M
      NSString *magString = [[[components objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:1];
      NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
      self.currentEarthquake.magnitude = [formatter numberFromString:magString];
      self.currentEarthquake.place = [components objectAtIndex:1];
      [formatter release];
    }
  } else if ([elementName isEqualToString:@"updated"]) {
    //<updated>2008-04-29T19:10:01Z</updated>
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    self.currentEarthquake.lastUpdate = [formatter dateFromString:self.propertyValue];
    [formatter release];
  } else if ([elementName isEqualToString:@"georss:point"]) {
    NSArray *comp = [self.propertyValue componentsSeparatedByString:@" "];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *latituide = [formatter numberFromString:[comp objectAtIndex:0]];
    NSNumber *longitude = [formatter numberFromString:[comp objectAtIndex:1]];
    [formatter release];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latituide.floatValue
                                                      longitude:longitude.floatValue];
    self.currentEarthquake.location = location;
    [location release];
  } else if([elementName isEqualToString:@"entry"]) {
    SEL selector = @selector(parser:addEarthquake:);
    NSMethodSignature *sig = [(id)self.delegate methodSignatureForSelector:selector];
    if(nil != sig && [self.delegate respondsToSelector:selector]) {
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
      [invocation retainArguments];
      [invocation setTarget:self.delegate];
      [invocation setSelector:selector];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&_currentEarthquake atIndex:3];
      [invocation performSelectorOnMainThread:@selector(invoke) withObject:NULL waitUntilDone:NO];
    }
  }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  if(parseError.code != NSXMLParserDelegateAbortedParseError) {
    NSLog(@"parser error %@, userInfo %@", parseError, [parseError userInfo]);
  }
}

- (void) dealloc {
  self.connection = nil;
  
  xmlFreeParserCtxt(_xmlParserContext);
  _xmlParserContext = NULL;

  self.currentEarthquake = nil;
  self.propertyValue = nil;
  self.delegate = nil;
  self.retrieverQueue = nil;
  [_title release];
  [_updated release];
  [_point release];
  [super dealloc];
}

@end


#pragma mark SAX Parsing Callbacks

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes) 
{
  [((EarthquakeParser *)ctx) elementFound:localname prefix:prefix uri:URI 
                       namespaceCount:nb_namespaces namespaces:namespaces
                       attributeCount:nb_attributes defaultAttributeCount:nb_defaulted
                           attributes:(xmlSAX2Attributes*)attributes];
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                          const xmlChar *URI) 
{    
  [((EarthquakeParser *)ctx) endElement:localname prefix:prefix uri:URI];
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) 
{
  [((EarthquakeParser *)ctx) charactersFound:ch length:len];
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...) 
{
  va_list argList;
  va_start(argList, msg);
  [((EarthquakeParser *)ctx) parsingError:msg, argList];
}

static void endDocumentSAX(void *ctx) 
{
  [((EarthquakeParser *)ctx) endDocument];
}

static xmlSAXHandler simpleSAXHandlerStruct = 
{
  NULL,                       /* internalSubset */
  NULL,                       /* isStandalone   */
  NULL,                       /* hasInternalSubset */
  NULL,                       /* hasExternalSubset */
  NULL,                       /* resolveEntity */
  NULL,                       /* getEntity */
  NULL,                       /* entityDecl */
  NULL,                       /* notationDecl */
  NULL,                       /* attributeDecl */
  NULL,                       /* elementDecl */
  NULL,                       /* unparsedEntityDecl */
  NULL,                       /* setDocumentLocator */
  NULL,                       /* startDocument */
  endDocumentSAX,             /* endDocument */
  NULL,                       /* startElement*/
  NULL,                       /* endElement */
  NULL,                       /* reference */
  charactersFoundSAX,         /* characters */
  NULL,                       /* ignorableWhitespace */
  NULL,                       /* processingInstruction */
  NULL,                       /* comment */
  NULL,                       /* warning */
  errorEncounteredSAX,        /* error */
  NULL,                       /* fatalError //: unused error() get all the errors */
  NULL,                       /* getParameterEntity */
  NULL,                       /* cdataBlock */
  NULL,                       /* externalSubset */
  XML_SAX2_MAGIC,             // initialized? not sure what it means just do it
  NULL,                       // private
  startElementSAX,            /* startElementNs */
  endElementSAX,              /* endElementNs */
  NULL,                       /* serror */
};
