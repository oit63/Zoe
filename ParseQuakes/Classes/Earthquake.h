//
//  Earthquake.h
//  MapQuakes
//
//  Created by Bill Dudney on 6/19/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//
//  Licensed under the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0.html
//

#import <CoreLocation/CoreLocation.h>

@interface Earthquake : NSObject {
  NSString *_place;
  NSNumber *_magnitude;
  NSDate *_lastUpdate;
  NSString *_detailsURL;
  CLLocation *_location;
}

@property(nonatomic, copy) NSString *place;
@property(nonatomic, copy) NSNumber *magnitude;
@property(nonatomic, retain) NSDate *lastUpdate;
@property(nonatomic, copy) NSString *detailsURL;
@property(nonatomic, retain) CLLocation *location;

@end
