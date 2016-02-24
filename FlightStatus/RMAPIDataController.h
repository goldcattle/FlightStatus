//
//  RMAPIDataController.h
//  Stocx
//
//  Created by Rick Miron on 1/16/16.
//  Copyright © 2016 Rick Miron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RMAPIResponseHandler)(NSMutableDictionary *responseDictionary, NSError *error);

@interface RMAPIDataController : NSObject

+ (id)sharedInstance;
- (void)getFlightStatusForID:(NSString *)ID completionHandler:(RMAPIResponseHandler)handler;
- (void)getFlightArrivalStatusForCarrier:(NSString *)carrier flight:(NSString *)flight completionHandler:(RMAPIResponseHandler)handler;
- (void)getTrackingInformationForFlight:(NSString *)ID completionHandler:(RMAPIResponseHandler)handler;

@end
