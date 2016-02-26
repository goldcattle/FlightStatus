//
//  RMFlightStatsAPIGateway.h
//  FlightStatus
//
//  Created by Ricardo Miron on 2/23/16.
//  Copyright © 2016 Ricardo Miron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMFlightStatsAPIGateway : NSObject

- (NSURL *)getFlightStatsURLForID:(NSString *)ID;
- (NSURL *)getFlightArrivalStatus:(NSString *)carrier flightNumber:(NSString *)flight;
- (NSURL *)getTrackingInformationForFlight:(NSString *)ID;

@end
