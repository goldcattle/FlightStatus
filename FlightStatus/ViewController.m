//
//  ViewController.m
//  FlightStatus
//
//  Created by Ricardo Miron on 2/23/16.
//  Copyright © 2016 Ricardo Miron. All rights reserved.
//

#import "ViewController.h"
#import "RMAPIDataController.h"
#import "RMFlightStatus.h"

@interface ViewController () {
    NSTimer *flightTrackerTimer;
}

@property (strong, nonatomic) RMFlightStatus *flightStat;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reset];
    UIImage *image = [UIImage imageNamed:@"skurtLogo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.navigationController.navigationBar.topItem setTitleView:imageView];

    
    self.airlineTF.delegate = self;
    self.flightTF.delegate = self;
    [self validateTextFields];
}

- (void)getFlightStatus {
    
    [[RMAPIDataController sharedInstance] getFlightArrivalStatusForCarrier:self.airlineTF.text flight:self.flightTF.text completionHandler:^(NSMutableDictionary *responseDictionary, NSError *error) {
        if (error || responseDictionary == nil) {
            NSLog(@"Error : %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            [self reset];
        }
        else {
            self.flightStat = [[RMFlightStatus alloc]initWithDictionary:responseDictionary];
            if (self.flightStat != nil) {
                [self animateObjects];
                [self populateUIElements];
            }
            else {
                NSLog(@"Unable to retrieve flight status.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                                message:@"Unable to retrieve flight information."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
                [self reset];
            }
        }
    }];
}

- (void)populateUIElements {
    
    [self getTrackingInformation];
    if ([self.flightStat.flightStatus isEqualToString:@"In Flight"]) {
        flightTrackerTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0
                                                              target: self
                                                            selector: @selector(getTrackingInformation)
                                                            userInfo: nil
                                                             repeats: YES];
    }
    else {
        if (flightTrackerTimer) {
            [self killTimer];
        }
    }
 
    self.flightLabel.text = [NSString stringWithFormat:@"(%@) %@ %@", self.flightStat.flightCarrier, self.flightStat.flightCarrierName, self.flightStat.flightNumber];
    self.routeLabel.text = [NSString stringWithFormat:@"(%@) %@ to (%@) %@", self.flightStat.departurePort, self.flightStat.departureCity, self.flightStat.arrivalPort, self.flightStat.arrivalCity];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];

    self.departGateLabel.text = self.flightStat.departureGate;
    self.arrivalGateLabel.text = self.flightStat.arrivalGate;
    self.departDateLabel.text = [df stringFromDate:self.flightStat.localDepartDate];
    self.arrivalDateLabel.text = [df stringFromDate:self.flightStat.localArrivalDate];
    
    if ([self.flightStat.flightStatus isEqualToString:@"On Schedule"] ||
        [self.flightStat.flightStatus isEqualToString:@"Landed"] ||
        [self.flightStat.flightStatus isEqualToString:@"In Flight"]) {
        [self.flightStatusLabel setBackgroundColor:[UIColor colorWithRed:22/255.0 green:200/255.0 blue:0/255.0 alpha:1.0]];
    }
    else if ([self.flightStat.flightStatus isEqualToString:@"Redirected"] ||
             [self.flightStat.flightStatus isEqualToString:@"Diverted"] ||
             [self.flightStat.flightStatus isEqualToString:@"Cancelled"]) {
        [self.flightStatusLabel setBackgroundColor:[UIColor redColor]];

    }
    else {
        [self.flightStatusLabel setBackgroundColor:[UIColor lightGrayColor]];
    }
    self.flightStatusLabel.text = self.flightStat.flightStatus;
}

- (void)getTrackingInformation {
    
    [[RMAPIDataController sharedInstance] getTrackingInformationForFlight:self.flightStat.flightId completionHandler:^(NSMutableDictionary *responseDictionary, NSError *error) {
        [self.flightStat extractFlightTrack:responseDictionary];
        [self plotLocation];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"customPin";
        pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        pinView.image = [UIImage imageNamed:@"plane"];    //as suggested by Squatch
    }
    
    return pinView;
}

- (void)plotLocation {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if (self.flightStat.currentCoordinates.latitude != 0 && self.flightStat.currentCoordinates.longitude != 0) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = self.flightStat.currentCoordinates;
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        region.center = self.flightStat.currentCoordinates;
        region.span.longitudeDelta = 0.30f;
        region.span.latitudeDelta = 0.30f;
        [self.mapView setRegion:region animated:YES];
        [self.mapView addAnnotation:annotation];
    }
}

- (void)animateObjects {
    
    self.topViewTopConstraint.constant = 64;
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                         self.middleView.hidden = NO;
                         [UIView animateWithDuration:0.5
                                               delay:1.0
                                             options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.mapView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished){
                                              NSLog(@"Done2!");
                                              
                                          }];
                     }];
}

- (void)resetAnimation {
    self.topViewTopConstraint.constant = 252;
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
    }];


}

#pragma mark - Actions
- (IBAction)checkStatusButtonPressed:(id)sender {
    [self.view endEditing:YES];
    [self getFlightStatus];
    if (flightTrackerTimer) {
        [self killTimer];
    }
}

#pragma mark - Helper Methods
- (void) validateTextFields {
    
    if ((self.airlineTF.text.length > 0) && (self.flightTF.text.length > 0)) {
        self.actionButton.enabled = YES;
    }
    else {
        self.actionButton.enabled = NO;
    }
}

- (void)killTimer {
    [flightTrackerTimer invalidate];
    flightTrackerTimer = nil;
}

- (void)reset {
    self.airlineTF.text = nil;
    self.flightTF.text = nil;
    self.flightStat = nil;
    self.middleView.hidden = YES;
    self.mapView.alpha = 0.0;
    if (self.topViewTopConstraint.constant == 64) {
        [self resetAnimation];
    }
}

#pragma mark - UITextField Delegates
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self validateTextFields];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
