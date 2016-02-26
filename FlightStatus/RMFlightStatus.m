//
//  RMFlightStatus.m
//  FlightStatus
//
//  Created by Ricardo Miron on 2/23/16.
//  Copyright © 2016 Ricardo Miron. All rights reserved.
//

#import "RMFlightStatus.h"

@implementation RMFlightStatus {
    NSDateFormatter *df;
}

- (id)initWithDictionary:(NSMutableDictionary *)theDictionary {
    self = [super init];
    
    if (self) {
        if (theDictionary) {
            df= [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
            [self initializeValues];
            [self parseDictionary:theDictionary];
        }
        else {
            return nil;
        }
    }
    return self;
}

- (void)parseDictionary:theDictionary {
    
    NSDictionary *departureDict;
    NSDictionary *arrivalDict;
    
    NSArray *flightStatArray = [theDictionary objectForKey:@"flightStatuses"];
    if ([flightStatArray count] < 1) {
        return;
    }
    self.departurePort = [[flightStatArray valueForKey:@"departureAirportFsCode"] lastObject];
    self.arrivalPort = [[flightStatArray valueForKey:@"arrivalAirportFsCode"] lastObject];
    self.flightId = [[flightStatArray valueForKey:@"flightId"] lastObject];
    self.flightNumber = [[flightStatArray valueForKey:@"flightNumber"] lastObject];
    
    NSArray *airlinesArray = [[theDictionary objectForKey:@"appendix"] valueForKey:@"airlines"];
    NSArray *airportsArray = [[theDictionary objectForKey:@"appendix"] valueForKey:@"airports"];
    NSArray *requestArray = [[theDictionary objectForKey:@"request"] valueForKey:@"airline"];
    self.flightCarrier = [requestArray valueForKey:@"fsCode"];

    NSDictionary *airlineDict;
    for (NSDictionary *temp in airlinesArray) {
        if ([self.flightCarrier isEqualToString:[temp objectForKey:@"fs"]]) {
            airlineDict = temp;
        }
    }
    self.flightCarrierName = [airlineDict objectForKey:@"name"];

    NSArray *airportResourcesArray = [[flightStatArray valueForKey:@"airportResources"] lastObject];
    self.arrivalGate = [self deNilify:[airportResourcesArray valueForKey:@"arrivalGate"]];
    self.arrivalTerminal = [self deNilify:[airportResourcesArray valueForKey:@"arrivalTerminal"] ];
    self.departureGate = [self deNilify:[airportResourcesArray valueForKey:@"departureGate"]];
    self.departureTerminal = [self deNilify:[airportResourcesArray valueForKey:@"departureTerminal"]];
    
    if ([self.arrivalPort isEqualToString:[[airportsArray lastObject] objectForKey:@"faa"]]) {
        arrivalDict = [airportsArray lastObject];
        departureDict = [airportsArray objectAtIndex:[airportsArray count]-2];
    }
    else {
        arrivalDict = [airportsArray objectAtIndex:1];
        departureDict = [airportsArray objectAtIndex:0];
    }
    
    NSString *departureString = [NSString stringWithFormat:@"%@, %@, %@",
                                 [self deNilify:[departureDict objectForKey:@"city"]],
                                 [self deNilify:[departureDict objectForKey:@"stateCode"]],
                                 [self deNilify:[departureDict objectForKey:@"countryCode"]]];
    NSString *arrivalString = [NSString stringWithFormat:@"%@, %@, %@",
                               [self deNilify:[arrivalDict objectForKey:@"city"]],
                               [self deNilify:[arrivalDict objectForKey:@"stateCode"]],
                               [self deNilify:[arrivalDict objectForKey:@"countryCode"]]];
    self.departureCity = departureString;
    self.arrivalCity = arrivalString;
    
    NSString *oLat = [departureDict objectForKey:@"latitude"];
    NSString *oLon = [departureDict objectForKey:@"longitude"];
    NSString *dLat = [arrivalDict objectForKey:@"latitude"];
    NSString *dLon = [arrivalDict objectForKey:@"longitude"];
    self.originCoordinates = CLLocationCoordinate2DMake([oLat doubleValue], [oLon doubleValue]);
    self.destinationCoordinates = CLLocationCoordinate2DMake([dLat doubleValue], [dLon doubleValue]);
    
    NSString *arrivalDateString = [[[flightStatArray valueForKey:@"arrivalDate"] valueForKey:@"dateLocal"] lastObject];
    NSString *departureDateString = [[[flightStatArray valueForKey:@"departureDate"] valueForKey:@"dateLocal"] lastObject];
    NSDate *formattedArrivalDate = [df dateFromString: arrivalDateString];
    NSDate *formattedDepartureDate = [df dateFromString: departureDateString];
    
    if (![[[[[flightStatArray valueForKey:@"operationalTimes"] valueForKey:@"estimatedGateArrival"] valueForKey:@"dateLocal"] lastObject] isKindOfClass:[NSNull class]]) {
        NSDate *formattedEArrivalDate = [df dateFromString:[[[[flightStatArray valueForKey:@"operationalTimes"] valueForKey:@"estimatedGateArrival"] valueForKey:@"dateLocal"] lastObject]];
        self.localEstimatedArrivalDate = formattedEArrivalDate;
    }
    
    if (![[[[[flightStatArray valueForKey:@"operationalTimes"] valueForKey:@"actualRunwayDeparture"] valueForKey:@"dateLocal"] lastObject] isKindOfClass:[NSNull class]]) {
        NSDate *formattedADepartureDate = [df dateFromString:[[[[flightStatArray valueForKey:@"operationalTimes"] valueForKey:@"actualRunwayDeparture"] valueForKey:@"dateLocal"] lastObject]];
        self.localActualDepartDate = formattedADepartureDate;
    }
    
    self.localScheduledDepartDate = formattedDepartureDate;
    self.localScheduledArrivalDate = formattedArrivalDate;
    self.flightDuration = [[[flightStatArray valueForKey:@"flightDurations"] valueForKey:@"airMinutes"] lastObject];
    self.flightScheduledDuration = [[[flightStatArray valueForKey:@"flightDurations"] valueForKey:@"scheduledBlockMinutes"] lastObject];
    
    NSString *status = [[flightStatArray valueForKey:@"status"] lastObject];
    
    if ([status  isEqual: @"S"]) {
        self.flightStatus = @"Scheduled";
    }
    else if ([status  isEqual: @"A"]) {
        self.flightStatus = @"In Flight";
    }
    else if ([status  isEqual: @"U"]) {
        self.flightStatus = @"Unknown";
    }
    else if ([status  isEqual: @"R"]) {
        self.flightStatus = @"Redirected";
    }
    else if ([status  isEqual: @"L"]) {
        self.flightStatus = @"Landed";
    }
    else if ([status  isEqual: @"D"]) {
        self.flightStatus = @"Diverted";
    }
    else if ([status  isEqual: @"C"]) {
        self.flightStatus = @"Cancelled";
    }
    else if ([status  isEqual: @"NO"]) {
        self.flightStatus = @"Not Operational";
    }
    else {
        self.flightStatus = @"Unknown";
    }
}

- (void)extractFlightTrack:(NSMutableDictionary *)theDictionary {
    NSArray *flightStatArray = [theDictionary objectForKey:@"flightTrack"];
    NSArray *positionsArray = [flightStatArray valueForKey:@"positions"];
    NSDictionary *currentLocationDict;
    if ([positionsArray count] > 0) {
        currentLocationDict = [positionsArray objectAtIndex:0];
        NSString *latitude = [currentLocationDict objectForKey:@"lat"];
        NSString *longitude = [currentLocationDict objectForKey:@"lon"];
        self.currentCoordinates = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    }
}


#pragma mark - Utility Methods
- (void)initializeValues {
    self.flightId = nil;
    self.flightNumber = nil;
    self.flightCarrier = nil;
    self.flightCarrierName = nil;
    self.departureCity = nil;
    self.departurePort = nil;
    self.departureGate = nil;
    self.departureTerminal = nil;
    self.arrivalCity = nil;
    self.arrivalPort = nil;
    self.arrivalGate = nil;
    self.arrivalTerminal = nil;
    self.localScheduledDepartDate = nil;
    self.localScheduledArrivalDate = nil;
    self.localActualDepartDate = nil;
    self.localEstimatedArrivalDate = nil;
    self.flightDuration = nil;
    self.flightScheduledDuration = nil;
    self.flightStatus = nil;
    self.currentCoordinates = kCLLocationCoordinate2DInvalid;
    self.originCoordinates = kCLLocationCoordinate2DInvalid;
    self.destinationCoordinates = kCLLocationCoordinate2DInvalid;
}

- (NSString *)deNilify:(NSString *) string
{
    if(( string == nil ) || ((NSNull *) string == [NSNull null])) {
        return @"-";
    }
    return string;
}
/*
 
 <dateLocal>2012-06-05T18:10:00.000</dateLocal>	0..1	The local date and time in ISO-8601 format. yyyy-MM-dd'T'HH:mm:ss.SSS
 <dateUtc>2012-06-05T22:10:00.000Z</dateUtc>	0..1	The UTC date and time in ISO-8601 format. yyyy-MM-dd'T'HH:mm:ss.SSSZ

 
 <delays>	0..1	Any calculated delays for the flight based on operational times (scheduled, estimated and actual).
 <departureGateDelayMinutes>16 </departureGateDelayMinutes>	0..1	Calculated gate departure delay in whole minutes (Integer).
 <departureRunwayDelayMinutes>13 </departureRunwayDelayMinutes>	0..1	Calculated runway departure delay in whole minutes (Integer).
 <arrivalGateDelayMinutes>8 </arrivalGateDelayMinutes>	0..1	Calculated gate arrival delay in whole minutes (Integer).
 <arrivalRunwayDelayMinutes>7 </arrivalRunwayDelayMinutes>	0..1	Calculated runway arrival delay in whole minutes (Integer).
 
 
 
 <flightDurations>	0..1	Calculated flight durations based on operational times (scheduled, estimated and actual).
 <scheduledBlockMinutes>430 </scheduledBlockMinutes>	0..1	The calculated scheduled time between blocks (gate to gate) in whole minutes (Integer).
 <blockMinutes>425</blockMinutes>	0..1    The calculated time between blocks (gate to gate) in whole minutes (Integer). This will be the actual block time if available, otherwise it will be the current best estimate.
 <scheduledAirMinutes>407 </scheduledAirMinutes>	0..1	The calculated scheduled time in the air (runway to runway) in whole minutes (Integer).
 <airMinutes>412</airMinutes>	0..1	The calculated time in the air (runway to runway) in whole minutes (Integer). This will be the actual air time if available, otherwise it will be the current best estimate.
 <scheduledTaxiOutMinutes>7 </scheduledTaxiOutMinutes>	0..1	The calculated scheduled time for the plane to taxi out and take off (gate to runway) in whole minutes (Integer).
 <taxiOutMinutes>12</taxiOutMinutes>	0..1	The calculated time for the plane to taxi out and take off (gate to runway) in whole minutes (Integer). This will be the actual taxi out time if available, otherwise it will be the current best estimate.
 <scheduledTaxiInMinutes>14 </scheduledTaxiInMinutes>	0..1	The calculated scheduled time for the plane to land and taxi in (runway to gate) in whole minutes (Integer).
 <taxiInMinutes>13</taxiInMinutes>	0..1	The calculated time for the plane to land and taxi in (runway to gate) in whole minutes (Integer). This will be the actual taxi in time if available, otherwise it will be the current best estimate.
 
 
 
 - Scheduled (S) - A scheduled flight is one that is anticipated to depart and arrive according to either filed flight plans or published flight schedules. A Scheduled flight can transition to Cancelled, Active, or Unknown.
 
 - Active (A) - Active flights represent pushed back from gate and airborne flights. They may have departure information depending upon the availability of the data. An active flight may transition to Unknown, Landed, or Redirected. While active, FlightStats tracks information about departure, estimated arrival, and where available, positional data.
 
 - Unknown (U) - An unknown flight occurs when FlightStats cannot determine the final status of a flight from a data source in a reasonable amount of time. Note, this is a valid state rather than an error state. For example, ASDI information may not be available for certain flights internationally or the airline may not participate in a subscribed GDS.
 
 - Redirected (R) - The flight is in the air and has changed its destination to an unscheduled airport. After landing at an unscheduled airport, the state will change to Diverted.
 
 - Landed (L) - The flight landed at the scheduled airport.
 
 - Diverted (D) - The flight landed at an unscheduled airport.
 
 - Cancelled (C) - The flight was cancelled.
 
 - Not Operational (NO) - The flight appears to be from an outdated schedule or flight plan – meaning that when we queried the airline, it returned that the flight is not scheduled.
 */


@end
