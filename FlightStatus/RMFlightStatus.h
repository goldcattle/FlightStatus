//
//  RMFlightStatus.h
//  FlightStatus
//
//  Created by Ricardo Miron on 2/23/16.
//  Copyright © 2016 Ricardo Miron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RMFlightStatus : NSObject 

@property (strong, nonatomic) NSString *flightId;
@property (strong, nonatomic) NSString *flightNumber;
@property (strong, nonatomic) NSString *flightCarrier;
@property (strong, nonatomic) NSString *flightCarrierName;
@property (strong, nonatomic) NSString *departureCity;
@property (strong, nonatomic) NSString *departurePort;
@property (strong, nonatomic) NSString *departureGate;
@property (strong, nonatomic) NSString *departureTerminal;
@property (strong, nonatomic) NSString *arrivalCity;
@property (strong, nonatomic) NSString *arrivalPort;
@property (strong, nonatomic) NSString *arrivalGate;
@property (strong, nonatomic) NSString *arrivalTerminal;
@property (strong, nonatomic) NSDate *localScheduledDepartDate;
@property (strong, nonatomic) NSDate *localScheduledArrivalDate;
@property (strong, nonatomic) NSDate *localActualDepartDate;
@property (strong, nonatomic) NSDate *localEstimatedArrivalDate;
@property (strong, nonatomic) NSNumber *flightDuration;
@property (strong, nonatomic) NSNumber *flightScheduledDuration;
@property (strong, nonatomic) NSString *flightStatus;
@property (assign, nonatomic) CLLocationCoordinate2D currentCoordinates;
@property (assign, nonatomic) CLLocationCoordinate2D originCoordinates;
@property (assign, nonatomic) CLLocationCoordinate2D destinationCoordinates;


- (id)initWithDictionary:(NSMutableDictionary *)theDictionary;
- (void)extractFlightTrack:(NSMutableDictionary *)theDictionary;

@end
