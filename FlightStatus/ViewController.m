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
    UISwipeGestureRecognizer *swipeDownGestureRecognizer;
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

    self.flightTF.delegate = self;
    self.actionButton.exclusiveTouch = YES;
    self.actionButton2.exclusiveTouch = YES;
    self.statusView.layer.cornerRadius = 5;
}

- (void)getFlightStatus {
    
    NSString *modifiedString =  [[self.flightTF.text componentsSeparatedByCharactersInSet:
                                  [[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    //NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *flightNumber = [modifiedString stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
    NSString *airline = [modifiedString stringByTrimmingCharactersInSet:numberSet];
    
    [[RMAPIDataController sharedInstance] getFlightArrivalStatusForCarrier:airline flight:flightNumber completionHandler:^(NSMutableDictionary *responseDictionary, NSError *error) {
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
                [self populateUIElements];
                [self createSwipeDownGestureRecognizer];
                [self animateObjects];
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

- (void)getTrackingInformation {
    
    if (self.flightStat.flightId != nil) {
        [[RMAPIDataController sharedInstance] getTrackingInformationForFlight:self.flightStat.flightId completionHandler:^(NSMutableDictionary *responseDictionary, NSError *error) {
            if (error || responseDictionary == nil) {
                NSLog(@"Error : %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                                message:[error description]
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                [self.flightStat extractFlightTrack:responseDictionary];
                [self plotLocation];
            }
        }];
    }
    else {
        NSLog(@"Unable to retrieve tracking details.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                        message:@"Unable to retrieve flight information."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.flightTF resignFirstResponder];
    }
}

- (void)populateUIElements {
    
    [self getTrackingInformation];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    
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
    
    self.departGateLabel.text = [NSString stringWithFormat:@"Gate %@ (Terminal %@)", self.flightStat.departureGate, self.flightStat.departureTerminal];
    self.arrivalGateLabel.text = [NSString stringWithFormat:@"Gate %@ (Terminal %@)", self.flightStat.arrivalGate, self.flightStat.arrivalTerminal];
    if ([self.flightStat.flightStatus isEqualToString:@"Landed"] ||
        [self.flightStat.flightStatus isEqualToString:@"In Flight"]) {
        self.departDateLabel.text = [df stringFromDate:self.flightStat.localActualDepartDate];
        self.arrivalDateLabel.text = [df stringFromDate:self.flightStat.localEstimatedArrivalDate];
        self.header1Label.text = @"Departed";
    }
    else {
        self.departDateLabel.text = [df stringFromDate:self.flightStat.localScheduledDepartDate];
        self.arrivalDateLabel.text = [df stringFromDate:self.flightStat.localScheduledArrivalDate];
    }
    
    if ([self.flightStat.flightStatus isEqualToString:@"Landed"]) {
        self.header2Label.text = @"Arrived";
    }
    
    if ([self.flightStat.flightStatus isEqualToString:@"On Schedule"] ||
        [self.flightStat.flightStatus isEqualToString:@"Landed"] ||
        [self.flightStat.flightStatus isEqualToString:@"In Flight"]) {
        [self.statusView setBackgroundColor:[UIColor colorWithRed:22/255.0 green:200/255.0 blue:0/255.0 alpha:1.0]];
    }
    else if ([self.flightStat.flightStatus isEqualToString:@"Redirected"] ||
             [self.flightStat.flightStatus isEqualToString:@"Diverted"] ||
             [self.flightStat.flightStatus isEqualToString:@"Cancelled"]) {
        [self.statusView setBackgroundColor:[UIColor redColor]];

    }
    else {
        [self.statusView setBackgroundColor:[UIColor lightGrayColor]];
    }
    self.flightStatusLabel.text = self.flightStat.flightStatus;
    self.flightDurationLabel.text = [self getFlightDurationString];
}

- (void)plotLocation {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.span.longitudeDelta = 0.30f;
    region.span.latitudeDelta = 0.30f;

    
    if ([self.flightStat.flightStatus isEqualToString:@"Landed"]) {
        if (CLLocationCoordinate2DIsValid(self.flightStat.destinationCoordinates)) {
            annotation.coordinate = self.flightStat.destinationCoordinates;
            region.center = self.flightStat.destinationCoordinates;
            [self.mapView setRegion:region animated:YES];
            [self.mapView addAnnotation:annotation];
        }
    }
    else if ([self.flightStat.flightStatus isEqualToString:@"On Schedule"]){
        if (CLLocationCoordinate2DIsValid(self.flightStat.originCoordinates)) {
            annotation.coordinate = self.flightStat.originCoordinates;
            region.center = self.flightStat.originCoordinates;
            [self.mapView setRegion:region animated:YES];
            [self.mapView addAnnotation:annotation];
        }
    }
    else if ([self.flightStat.flightStatus isEqualToString:@"In Flight"]) {
        if (CLLocationCoordinate2DIsValid(self.flightStat.currentCoordinates)) {
            annotation.coordinate = self.flightStat.currentCoordinates;
            region.center = self.flightStat.currentCoordinates;
            [self.mapView setRegion:region animated:YES];
            [self.mapView addAnnotation:annotation];
        }
    }
    else {
        region = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(180, 360));
        [self.mapView setRegion:region animated:YES];
    }
}

#pragma mark - Animations
- (void)animateObjects {
    
    self.topViewTopConstraint.constant = -self.topView.frame.size.height;
    self.middleViewTopConstraint.constant = 0;
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                         self.middleView.hidden = NO;
                         [self animateMiddleView];
                         [UIView animateWithDuration:0.5
                                               delay:0.5
                                             options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.mapView.alpha = 1.0;
                                              self.actionButton2.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];
}

- (void)animateMiddleView
{
    self.flightLabel.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width * -1, 0);
    self.routeLabel.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width * -1, 0);
    self.header1Label.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width * -1, 0);
    self.header2Label.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width * -1, 0);
    self.departDateLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height * 1);
    self.departGateLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height * 1);
    self.arrivalDateLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height * 1);
    self.arrivalGateLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height * 1);
    self.statusView.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width * 1, 0);
    
    [UIView animateWithDuration:0.80 delay:0.07 usingSpringWithDamping:.70 initialSpringVelocity:.8 options:0 animations:^{
        self.flightLabel.transform = CGAffineTransformIdentity;
        self.header1Label.transform = CGAffineTransformIdentity;
        self.header2Label.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.80 delay:0.0 usingSpringWithDamping:.85 initialSpringVelocity:.8 options:0 animations:^{
            self.routeLabel.transform = CGAffineTransformIdentity;
            self.departDateLabel.transform = CGAffineTransformIdentity;
            self.departGateLabel.transform = CGAffineTransformIdentity;
            self.arrivalDateLabel.transform = CGAffineTransformIdentity;
            self.arrivalGateLabel.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                                 self.statusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {

            }];
        }];
    }];
}

- (void)resetAnimation {
    self.topViewTopConstraint.constant = 200;
    self.middleViewTopConstraint.constant = 184;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
    }];
}

- (void)shiftTopView {
    self.topViewTopConstraint.constant = 100;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)unshiftTopView {
    self.topViewTopConstraint.constant = 200;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Map Delegate
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
        pinView.image = [UIImage imageNamed:@"plane"];
    }
    
    return pinView;
}

#pragma mark - Actions
- (IBAction)checkStatusButtonPressed:(id)sender {
    if ([self validateTextFields]) {
        [self.view endEditing:YES];
        [self getFlightStatus];
        if (flightTrackerTimer) {
            [self killTimer];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                        message:@"You must enter a valid flight number in order to proceed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)scheduleRentalButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Complete"
                                                    message:@"The prototype will now be reset."
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self resetAnimation];
    [self reset];
}

#pragma mark - Helper Methods
- (BOOL) validateTextFields {
    
    if (self.flightTF.text.length > 0) {
        return YES;
    }
    return NO;
}

- (void)killTimer {
    [flightTrackerTimer invalidate];
    flightTrackerTimer = nil;
}

- (NSString *)getFlightDurationString {
    
    NSString *returnString;
    int minutes;
    int hours;
    
    if ([self.flightStat.flightDuration isKindOfClass:[NSNull class]]) {
        minutes = [self.flightStat.flightScheduledDuration integerValue]%60;
        hours = (int)([self.flightStat.flightScheduledDuration integerValue] - minutes)/60;
        returnString = [NSString stringWithFormat:@"Scheduled for %d hours %d minutes", hours, minutes];
    }
    else {
        // On completion of flight only
        minutes = [self.flightStat.flightDuration integerValue]%60;
        hours = (int)([self.flightStat.flightDuration integerValue] - minutes)/60;
        returnString = [NSString stringWithFormat:@"Duration %d hours %d minutes", hours, minutes];
    }
    
//    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:self.flightStat.localActualDepartDate];
//    double mins = diff/60;
//    int timeleft = [self.flightStat.flightScheduledDuration intValue] - mins;
    
    return returnString;
}

- (void)reset {
    if (flightTrackerTimer) {
        [self killTimer];
    }
    self.flightTF.text = nil;
    self.flightStat = nil;
    self.middleView.hidden = YES;
    self.mapView.alpha = 0.0;
    self.actionButton2.alpha = 0.0;
    self.header1Label.text = @"Departs";
    self.header2Label.text = @"Arrives";
}

#pragma mark - Gesture Methods
- (void)createSwipeDownGestureRecognizer {
    swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDownGestureRecognizer];
}

- (void)removeSwipeDownGestureRecognizer {
    [self.view removeGestureRecognizer:swipeDownGestureRecognizer];
}

- (void)handleSwipeDownFrom:(UIGestureRecognizer*)recognizer {
    [self resetAnimation];
    [self reset];
}

#pragma mark - UITextField Delegates
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self validateTextFields];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self shiftTopView];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self unshiftTopView];
    [self.view endEditing:YES];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
