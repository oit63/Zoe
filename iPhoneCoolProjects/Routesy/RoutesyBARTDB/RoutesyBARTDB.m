#import <Foundation/Foundation.h>
#import <sqlite3.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	sqlite3 *database;
	sqlite3_stmt *statement;
	NSString *filename = @"routesy.db";
	sqlite3_open([filename UTF8String], &database);
	
	char *sql = "CREATE TABLE stations ( \
							  id VARCHAR(16), \
							  name VARCHAR(64), \
	                          lat FLOAT, \
							  lon FLOAT, \
							  PRIMARY KEY (id))";
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		NSLog(@"Table created");
		sqlite3_step(statement);
		sqlite3_reset(statement);
	}
	
	NSData *stationDirectoryHTMLData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.bart.gov/stations"]] returningResponse:nil error:nil];
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:stationDirectoryHTMLData options:NSXMLDocumentTidyHTML error:nil];
	
	NSString *query = @"//div[@id=\"stations-directory\"]/ul//a/@href";
	NSArray *hrefs = [doc nodesForXPath:query error:nil];
	
	NSString *stationLink;
	NSXMLNode *stationNode;
	
	NSData *stationPageHTMLData;
	NSString *stationPageHTML, *scriptVars, *line, *key, *value;
	
	NSMutableDictionary *locationNodes;
	NSArray *lines, *lineComponents;
	
	sql = "INSERT INTO stations (id, name, lat, lon) VALUES (?, ?, ?, ?)";
	
	for (stationNode in hrefs) {
		stationLink = [[stationNode stringValue] stringByReplacingOccurrencesOfString:@"index" withString:@"neighborhood"];
		
		stationPageHTMLData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bart.gov/stations/%@", stationLink]]] returningResponse:nil error:nil];
		stationPageHTML = [[NSString alloc] initWithData:stationPageHTMLData encoding:NSUTF8StringEncoding];
		
		NSRange startScriptRange = [stationPageHTML rangeOfString:@"inStn.Latitude ="];
		NSRange endScriptRange = [stationPageHTML rangeOfString:@"inStn.UseLatLong"];
		
		int startAt = startScriptRange.location;
		int length = endScriptRange.location - startAt;
		
		scriptVars = [stationPageHTML substringWithRange:NSMakeRange(startAt, length - 2)];
		
		// Get rid of the quotes and semicolons
		scriptVars = [[scriptVars stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@";" withString:@""];		
		
		locationNodes = [NSMutableDictionary dictionary];
		
		// Split the lines of script variables by using line breaks
		lines = [scriptVars componentsSeparatedByString:@"\r\n"];
		
		for (line in lines) {
			lineComponents = [line componentsSeparatedByString:@" = "];
			
			// Get the name and value of each variable and put them into a dictionary
			key = [[[lineComponents objectAtIndex:0] stringByReplacingOccurrencesOfString:@"inStn." withString:@""] lowercaseString];
			value = [lineComponents objectAtIndex:1];
			[locationNodes setObject:value forKey:key];
		}
		
		sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
		sqlite3_bind_text(statement, 1, [[locationNodes objectForKey:@"palm"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 2, [[locationNodes objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(statement, 3, [[locationNodes objectForKey:@"latitude"] doubleValue]);
		sqlite3_bind_double(statement, 4, [[locationNodes objectForKey:@"longitude"] doubleValue]);
		sqlite3_step(statement);
		sqlite3_reset(statement);
	}

    [pool drain];
    return 0;
}
