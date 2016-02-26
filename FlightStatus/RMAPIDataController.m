//
//  RMAPIDataController.m
//  FlightStatus
//
//  Created by Rick Miron on 2/23/16.
//  Copyright © 2016 Rick Miron. All rights reserved.
//

#import "RMAPIDataController.h"
#import "RMHTTPController.h"
#import "RMFlightStatsAPIGateway.h"


typedef void(^APIResponseHandler)(NSMutableDictionary *responseDictionary, NSError *error);

@interface RMAPIDataController (){
    RMFlightStatsAPIGateway *apiGateway;
}

@end

@implementation RMAPIDataController

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RMAPIDataController alloc]init];
    });
    
    return sharedInstance;
}

- (id)init {
    
    self = [super init];
    if (self) {
        apiGateway = [[RMFlightStatsAPIGateway alloc]init];
    }
    
    return self;
}

#pragma mark - FlightStats API

- (void)getFlightStatusForID:(NSString *)ID completionHandler:(RMAPIResponseHandler)handler {
    
    NSURL *url = [apiGateway getFlightStatsURLForID:ID];
    
    if (url) {
        [self callAPI:url withDictionary:nil handler:^(NSMutableDictionary *responseDictionary, NSError *error){
            handler((NSMutableDictionary *)responseDictionary,error);
        }];
    }
    else {
        // Create the NSError
        handler(nil,nil);
    }
}

- (void)getFlightArrivalStatusForCarrier:(NSString *)carrier flight:(NSString *)flight completionHandler:(RMAPIResponseHandler)handler {
    NSURL *url = [apiGateway getFlightArrivalStatus:carrier flightNumber:flight];
    
    if (url) {
        [self callAPI:url withDictionary:nil handler:^(NSMutableDictionary *responseDictionary, NSError *error){
            handler((NSMutableDictionary *)responseDictionary,error);
        }];
    }
    else {
        // Create the NSError
        handler(nil,nil);
    }
}

- (void)getTrackingInformationForFlight:(NSString *)ID completionHandler:(RMAPIResponseHandler)handler {
    
    NSURL *url = [apiGateway getTrackingInformationForFlight:ID];

    if (url) {
        [self callAPI:url withDictionary:nil handler:^(NSMutableDictionary *responseDictionary, NSError *error){
            handler((NSMutableDictionary *)responseDictionary,error);
        }];
    }
    else {
        // Create the NSError
        handler(nil,nil);
    }
}


#pragma mark - HTTPController
- (void)callAPI:(NSURL *)theURL withDictionary:(NSMutableDictionary *)dictionary handler:(APIResponseHandler)handler;
{
    [RMHTTPController downloadDataFromURL:theURL parameters:dictionary withCompletionHandler:^(NSData *data)
     {
         // Check if any data returned.
         if (data !=nil)
         {
             NSError *error;
             NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             //NSLog(@"%@", [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] class]);
             //NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
             
             if (error != nil)
             {
                 NSLog(@"%@", [error localizedDescription]);
                 handler(nil, error);
             }
             else
             {
                 handler(returnedDict, nil);
             }
         }
         else
         {
             NSError *replyError;
             // Populate the replyError
             handler(nil, replyError);
         }
     }];
}

@end
