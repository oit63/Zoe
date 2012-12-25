//
//  RootViewController.h
//  ParseQuakes
//
//  Created by Bill Dudney on 9/1/09.
//  Copyright Gala Factory 2009. All rights reserved.
//
//  Licensed under the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0.html
//

#import "EarthquakeParser.h"

@interface RootViewController : UITableViewController <EarthquakeParserDelegate> 
{
  NSMutableArray *_earthquakes;
  BOOL _shouldUseLibXML;
}

@property (nonatomic, retain) NSMutableArray *earthquakes;

@end
