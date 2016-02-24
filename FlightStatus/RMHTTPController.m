//
//  RMHTTPController.m
//  Stocx
//
//  Created by Rick Miron on 1/16/16.
//  Copyright © 2016 Rick Miron. All rights reserved.
//

#import "RMHTTPController.h"

@implementation RMHTTPController

#pragma mark - Download Data

+ (void)downloadDataFromURL:(NSURL *)url parameters:(NSDictionary *)parameters withCompletionHandler:(void (^)(NSData *))completionHandler
{
    // Instantiate a session configuration object.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Instantiate a session object.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // If parameters exist, append it to url
    if (parameters != nil)
    {
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&jsonError];
        if (jsonError) {
            //return error
        }
        NSString *urlString = [url absoluteString];
        NSString *queryString = [NSString stringWithFormat:@"?parameters=%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        NSString *urlPlusQuery = [urlString stringByAppendingString: queryString];
        
        NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
        url = [NSURL URLWithString:[urlPlusQuery stringByAddingPercentEncodingWithAllowedCharacters:set]];
    }
    
    // Create a request object.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:40.0];
    // Create a data task object to perform the data downloading.
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            // If any error occurs then just display its description on the console.
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            // If no error occurs, check the HTTP status code.
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            
            // If it's other than 200, then show it on the console.
            if (HTTPStatusCode != 200) {
                NSLog(@"HTTP status code = %ld", (long)HTTPStatusCode);
            }
            
            // Call the completion handler with the returned data on the main thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data);
            }];
        }
    }];
    
    // Resume the task.
    [task resume];
}


@end
