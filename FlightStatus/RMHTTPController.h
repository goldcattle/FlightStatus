//
//  RMHTTPController.h
//  FlightStatus
//
//  Created by Rick Miron on 2/23/16.
//  Copyright © 2016 Rick Miron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMHTTPController : NSObject

+ (void)downloadDataFromURL:(NSURL *)url parameters:(NSDictionary *)parameters withCompletionHandler:(void (^)(NSData *))completionHandler;

@end
