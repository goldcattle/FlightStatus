//
//  RMFlightStatsAPIGateway.m
//  FlightStatus
//
//  Created by Ricardo Miron on 2/23/16.
//  Copyright © 2016 Ricardo Miron. All rights reserved.
//

#import "RMFlightStatsAPIGateway.h"

#define kURLString @"https://api.flightstats.com/flex/flightstatus/rest"
#define kAppID @"a17490f6"
#define kAppKey @"5b6abc5506b3e7af1845a19443c16bbb"

@implementation RMFlightStatsAPIGateway

// curl -v  -X GET "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/JBU746?appId=91b929e6&appKey=is2eebba75c50ce13c31b9ef0b331fb93a"

- (NSURL *)getFlightStatsURLForID:(NSString *)ID {
    
    NSString *api = @"/v2/json/flight/status/";
    NSString *apiURL = [NSString stringWithFormat:@"%@%@%@?appId=%@&appKey=%@", kURLString, api, ID, kAppID, kAppKey];
    
    return [NSURL URLWithString:apiURL];
}

// curl -v  -X GET "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/AA/100/arr/2016/2/23?appId=91b929e6&appKey=2eebba75c50ce13c31b9ef0b331fb93a&utc=false"

- (NSURL *)getFlightArrivalStatus:(NSString *)carrier flightNumber:(NSString *)flight {
    
    NSString *api = @"/v2/json/flight/status/";
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    NSString *theDate = [dateFormat stringFromDate:date];

    NSString *apiURL = [NSString stringWithFormat:@"%@%@%@/%@/arr/%@?appId=%@&appKey=%@", kURLString, api, carrier, flight, theDate, kAppID, kAppKey];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString* webStringURL = [apiURL stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    
    return [NSURL URLWithString:webStringURL];
}

- (NSURL *)getTrackingInformationForFlight:(NSString *)ID {
    
    NSString *api = @"/v2/json/flight/track/";
    NSString *apiURL = [NSString stringWithFormat:@"%@%@%@?appId=%@&appKey=%@", kURLString, api, ID, kAppID, kAppKey];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString* webStringURL = [apiURL stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    
    return [NSURL URLWithString:webStringURL];
}

@end
