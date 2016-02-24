//
//  ViewController.h
//  FlightStatus
//
//  Created by Ricardo Miron on 2/23/16.
//  Copyright © 2016 Ricardo Miron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *middleView;

@property (weak, nonatomic) IBOutlet UITextField *airlineTF;
@property (weak, nonatomic) IBOutlet UITextField *flightTF;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (weak, nonatomic) IBOutlet UILabel *flightLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *flightStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *departGateLabel;
@property (weak, nonatomic) IBOutlet UILabel *departDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalGateLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;

- (IBAction)checkStatusButtonPressed:(id)sender;


@end

