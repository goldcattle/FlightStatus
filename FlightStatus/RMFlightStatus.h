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
@property (strong, nonatomic) NSString *arrivalCity;
@property (strong, nonatomic) NSString *arrivalPort;
@property (strong, nonatomic) NSString *arrivalGate;
@property (strong, nonatomic) NSDate *localDepartDate;
@property (strong, nonatomic) NSDate *localArrivalDate;
@property (strong, nonatomic) NSString *flightStatus;
@property (assign, nonatomic) CLLocationCoordinate2D currentCoordinates;

- (id)initWithDictionary:(NSMutableDictionary *)theDictionary;
- (void)extractFlightTrack:(NSMutableDictionary *)theDictionary;


@end
