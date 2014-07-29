//
//  TrackingViewController.h
//  MMDrawerControllerKitchenSink
//
//  Created by admin on 7/17/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyLocationManager.h"
#import "MyUser.h"
#import "MyRoute.h"

@interface TrackingViewController : UIViewController <MyLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbGPS;
@property (weak, nonatomic) IBOutlet UIButton *btnStartStop;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *lbInfo0;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription0;

@property (weak, nonatomic) IBOutlet UILabel *lbInfo1;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription1;

@property (weak, nonatomic) IBOutlet UILabel *lbInfo2;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription2;

- (void) stopTracking ;
- (IBAction)btnClicked:(id)sender;
- (IBAction)showUserLocation:(id)sender;

@end
