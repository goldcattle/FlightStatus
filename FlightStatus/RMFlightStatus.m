//
//  RMFlightStatus.m
//  FlightStatus
//
//  Created by Ricardo Miron on 2/23/16.
//  Copyright © 2016 Ricardo Miron. All rights reserved.
//

#import "RMFlightStatus.h"

@implementation RMFlightStatus

- (id)initWithDictionary:(NSMutableDictionary *)theDictionary {
    self = [super init];
    
    if (self) {
        if (theDictionary) {
            
            NSArray *flightStatArray = [theDictionary objectForKey:@"flightStatuses"];
            if ([flightStatArray count] < 1) {
                return nil;
            }
            NSArray *appendixArray = [theDictionary objectForKey:@"appendix"];
            NSArray *airlinesArray = [appendixArray valueForKey:@"airlines"];

            self.flightCarrier = [[flightStatArray valueForKey:@"carrierFsCode"] lastObject];
            NSDictionary *airlineDict;
            for (NSDictionary *temp in airlinesArray) {
                if ([self.flightCarrier isEqualToString:[temp objectForKey:@"fs"]]) {
                    airlineDict = temp;
                }
            }
            
            
            NSArray *airportResourcesArray = [[flightStatArray valueForKey:@"airportResources"] lastObject];
            NSArray *airportsArray = [appendixArray valueForKey:@"airports"];
            
            self.departurePort = [[flightStatArray valueForKey:@"departureAirportFsCode"] lastObject];
            self.arrivalPort = [[flightStatArray valueForKey:@"arrivalAirportFsCode"] lastObject];
            
            NSDictionary *departureDict;
            NSDictionary *arrivalDict;
            
            if ([self.arrivalPort isEqualToString:[[airportsArray lastObject] objectForKey:@"faa"]]) {
                arrivalDict = [airportsArray lastObject];
                departureDict = [airportsArray objectAtIndex:[airportsArray count]-2];
            }
            else {
                arrivalDict = [airportsArray objectAtIndex:1];
                departureDict = [airportsArray objectAtIndex:0];
            }
            
            NSString *departureString = [NSString stringWithFormat:@"%@, %@, %@",
                                         [departureDict objectForKey:@"city"],
                                         [departureDict objectForKey:@"stateCode"],
                                         [departureDict objectForKey:@"countryCode"]];
            NSString *arrivalString = [NSString stringWithFormat:@"%@, %@, %@",
                                         [arrivalDict objectForKey:@"city"],
                                         [arrivalDict objectForKey:@"stateCode"],
                                         [arrivalDict objectForKey:@"countryCode"]];
            self.departureCity = departureString;
            self.arrivalCity = arrivalString;
            
            NSString *arrivalGate = [airportResourcesArray valueForKey:@"arrivalGate"];
            NSString *arrivalTerminal = [airportResourcesArray valueForKey:@"arrivalTerminal"];
            NSString *departureGate = [airportResourcesArray valueForKey:@"departureGate"];
            NSString *departureTerminal = [airportResourcesArray valueForKey:@"departureTerminal"];
            
            self.flightId = [[flightStatArray valueForKey:@"flightId"] lastObject]; //Per instructions
            self.flightNumber = [[flightStatArray valueForKey:@"flightNumber"] lastObject];
            self.departureGate = [NSString stringWithFormat:@"Gate %@ (Terminal %@)", departureGate, departureTerminal];
            self.arrivalGate = [NSString stringWithFormat:@"Gate %@ (Terminal %@)", arrivalGate, arrivalTerminal];
            self.flightCarrierName = [airlineDict objectForKey:@"name"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
            
            NSDate *formattedArrivalDate = [df dateFromString:[[[flightStatArray valueForKey:@"arrivalDate"] valueForKey:@"dateLocal"] lastObject]];
            NSDate *formattedDepartureDate = [df dateFromString:[[[flightStatArray valueForKey:@"departureDate"] valueForKey:@"dateLocal"] lastObject]];
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
                self.flightStatus = @"On Schedule";
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
    }
    return self;
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
/*
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
