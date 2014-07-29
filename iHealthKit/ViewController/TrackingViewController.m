//
//  TrackingViewController.m
//  MMDrawerControllerKitchenSink
//
//  Created by admin on 7/17/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "TrackingViewController.h"
#import "AppDelegate.h"
#import "MyVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "RouteViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    InfoType_Duration,
    InfoType_Distance,
    InfoType_Velocity,
    InfoType_AvgSpeed,
    InfoType_CurSpeed,
    InfoType_MaxSpeed,
    InfoType_AvgPace,
    InfoType_CurPace,
    InfoType_Calories,
    InfoType_Clock
} InfoType;

@interface TrackingViewController ()

@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolylineView* routeView;

@property (nonatomic, strong) NSMutableArray* routePoints;
@property (nonatomic, strong) NSMutableArray* locationDatatoStore;
@property (nonatomic, strong) CLLocation* lastLocation;

@property (nonatomic) float calories;
@property (nonatomic) float distance;
@property (nonatomic) float curSpeed;
@property (nonatomic) float averageSpeed;
@property (nonatomic) float maxSpeed;
@property NSInteger trainingType;

@property float curUser_Weight;

@property (nonatomic) NSDate* startTime;
@property (nonatomic) NSDate* endTime;

@property (nonatomic) NSTimer* timer;

@property (nonatomic, readonly) NSMutableDictionary* MET_VALUE;

@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic) BOOL needUserLocation;

@property (strong, nonatomic) NSArray* listInfoView;

@end


@implementation TrackingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([CommonFunctions getTrackingStatus]) {
        [self stopTracking];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"Activity"];
    
    _curUser_Weight = [[[CoreDataFuntions getCurUser] weight] floatValue];
    
    
    [self setupLeftMenuButton];
    
    _MET_VALUE = [[NSMutableDictionary alloc] init];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:4.0f] forKey:@"Walk"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:6.0f] forKey:@"Run4mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:8.3f] forKey:@"Run5mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:9.8f] forKey:@"Run6mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:11.0f] forKey:@"Run7mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:11.8f] forKey:@"Run8mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:12.8f] forKey:@"Run9mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:14.5f] forKey:@"Run10mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:16.0f] forKey:@"Run11mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:19.0f] forKey:@"Run12mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:19.8f] forKey:@"Run13mph"];
    [_MET_VALUE setValue:[NSNumber numberWithFloat:23.0f] forKey:@"Run14mph"];
    
    [MyLocationManager shareLocationManager].delegate = self;
    [_mapView setDelegate:self];
    _mapView.showsUserLocation = YES;
    
    [[MyLocationManager shareLocationManager] prepLocationUpdates];
    
    _needUserLocation = YES;
    _locationDatatoStore = [[NSMutableArray alloc] init];
    
    _listInfoView = [NSArray arrayWithObjects:InfoType_Duration, InfoType_Distance, InfoType_AvgSpeed, InfoType_Calories, nil];
    
    [self resetData];
    [self displayInfoViews];
}

- (void) displayInfoViews {
    NSUserDefaults* preference = [NSUserDefaults standardUserDefaults];
    NSInteger distanceType = [preference integerForKey:@"DistanceType"];
    NSInteger velocityUnit = [preference integerForKey:@"VelocityUnit"];
    NSInteger distanceUnit = [preference integerForKey:@"DistanceUnit"];
    
    
    if (distanceType == 0) {
        //metric system
        if (velocityUnit == 0) {
            _lbDescription2.text = [NSString stringWithFormat:@"Avg.Speed (km/h)"];
        } else if (velocityUnit == 1) {
            _lbDescription2.text = [NSString stringWithFormat:@"Avg.Speed (m/s)"];
        }
        
        if (distanceUnit == 0) {
            _lbDescription1.text = [NSString stringWithFormat:@"Distance (km)"];
        }
        else if (distanceUnit == 1) {
            _lbDescription1.text = [NSString stringWithFormat:@"Distance (m)"];

        }
    }
    else if (distanceType == 1) {
        if (velocityUnit == 0) {
            _lbDescription2.text = [NSString stringWithFormat:@"Avg.Speed (mph)"];
        }
        else if (velocityUnit == 1) {
            _lbDescription2.text = [NSString stringWithFormat:@"Avg.Speed (fps)"];
        }
    }
    
    _lbDescription0.text = @"Duration";    
    
    _lbInfo1.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertDistance:_distance]];
    _lbInfo2.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:_averageSpeed]];
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)setupRightMenuButton{
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClicked:(id)sender {
    if ([_btnStartStop.titleLabel.text isEqualToString:@"Stop"]) {
        //stop
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warining!" message:@"Do you want to stop tracking this activity?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [alert show];
        //[self stopTracking];
    }
    else {
        //start
        [self startTracking];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self stopTracking];
            break;
        default:
            break;
    }
}

- (void) startTracking {
    [self resetData];
    [[MyLocationManager shareLocationManager] startLocationUpdates];
    _calories = 0;
    
    [_btnStartStop setTitle:@"Stop" forState:UIControlStateNormal];
    [_btnStartStop setBackgroundColor:[UIColor colorWithRed:212.0/255 green:61.0/255 blue:79.0/255 alpha:1.0]];
    [CommonFunctions setTrackingStatus:YES];
}

- (void) stopTracking {
    [[MyLocationManager shareLocationManager] stopLocationUpdates];
    [[MyLocationManager shareLocationManager] resetLocationUpdates];
    
    [_btnStartStop setTitle:@"Start" forState:UIControlStateNormal];
    [_btnStartStop setBackgroundColor:[UIColor colorWithRed:105.0/255 green:208.0/255 blue:65.0/255 alpha:1.0]];
    
    NSArray* overlays = [_mapView overlays];
    [_mapView removeOverlays:overlays];
    
    [CommonFunctions setTrackingStatus:NO];
    
    RouteViewController* routeVC = [[RouteViewController alloc] initNewRoute:_startTime endtime:_endTime distance:_distance maxSpeed:_maxSpeed averageSpeed:_averageSpeed trainingType:_trainingType calories:_calories locationData:_locationDatatoStore routePoints:_routePoints];
    
    [self.navigationController pushViewController:routeVC animated:YES];
    [_timer invalidate];
    [self resetData];
}

- (void) resetData {
    _startTime = nil;
    _endTime = nil;
    _distance = 0;
    _maxSpeed = 0;
    _curSpeed = 0;
    _averageSpeed = 0;
    _trainingType = 0;
    _calories = 0;
    
    _needUserLocation = YES;
    [_locationDatatoStore removeAllObjects];
    if (_routePoints == nil) {
        _routePoints = [[NSMutableArray alloc] init];
    } else {
        [_routePoints removeAllObjects];
    }
    
}

- (NSMutableDictionary*) locationToDictionary: (CLLocation*) location withSpeed: (NSNumber*) speed {
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:@"latitude"];
    [dictionary setValue:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithFloat:location.altitude] forKey:@"altitude"];
    [dictionary setValue:speed forKey:@"speed"];
    [dictionary setValue:[NSDateFormatter localizedStringFromDate:location.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle] forKey:@"timeStamp"];
    
    return dictionary;
}


- (void) drawRouteLine: (CLLocationCoordinate2D) lastLocationCoordinate toCurrentLocation: (CLLocationCoordinate2D) curLocationCoordinate {
    
    MKMapPoint* mapPoints = malloc(sizeof(CLLocationCoordinate2D) * 2);
    
    mapPoints[0] = MKMapPointForCoordinate(lastLocationCoordinate);
    mapPoints[1] = MKMapPointForCoordinate(curLocationCoordinate);
    _routeLine = [MKPolyline polylineWithPoints:mapPoints count:2];
    
    [_mapView addOverlay:_routeLine];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	
	if(overlay == _routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now.
        if (_routeView) {
            [_routeView removeFromSuperview];
        }
        
        _routeView = [[MKPolylineView alloc] initWithPolyline:_routeLine];
        _routeView.fillColor = [UIColor colorWithRed:0 green:0.35 blue:1 alpha:0.9];
        _routeView.strokeColor = [UIColor colorWithRed:0 green:0.35 blue:1 alpha:0.9];
        _routeView.lineWidth = 5;
        
		overlayView = _routeView;
	}
	
	return overlayView;
}

/*
[_MET_VALUE setValue:[NSNumber numberWithFloat:6.0f] forKey:@"Run4mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:8.3f] forKey:@"Run5mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:9.8f] forKey:@"Run6mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:11.0f] forKey:@"Run7mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:11.8f] forKey:@"Run8mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:12.8f] forKey:@"Run9mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:14.5f] forKey:@"Run10mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:16.0f] forKey:@"Run11mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:19.0f] forKey:@"Run12mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:19.8f] forKey:@"Run13mph"];
[_MET_VALUE setValue:[NSNumber numberWithFloat:23.0f] forKey:@"Run14mph"];
*/

-(void) calculateCalories:(CLLocation*) newLocation withSpeed: (float) speed {
    CLLocation* oldLocation = [_routePoints lastObject];
    NSTimeInterval curTime = [newLocation.timestamp timeIntervalSinceNow] - [oldLocation.timestamp timeIntervalSinceNow];
#warning change MET value later
    float METValue;
    float speedInMPH = [CommonFunctions convertMPStoMiPH:speed];
    if (speedInMPH < 3.5) {
        METValue = [_MET_VALUE[@"Walk"] floatValue];
    } else if (speedInMPH < 4.5) {
        METValue = [_MET_VALUE[@"Run4mph"] floatValue];
    } else if (speedInMPH < 5.5) {
        METValue = [_MET_VALUE[@"Run5mph"] floatValue];
    } else if (speedInMPH < 6.5) {
        METValue = [_MET_VALUE[@"Run6mph"] floatValue];
    } else if (speedInMPH < 7.5) {
        METValue = [_MET_VALUE[@"Run7mph"] floatValue];
    } else if (speedInMPH < 8.5) {
        METValue = [_MET_VALUE[@"Run8mph"] floatValue];
    } else if (speedInMPH < 9.5) {
        METValue = [_MET_VALUE[@"Run9mph"] floatValue];
    } else if (speedInMPH < 10.5) {
        METValue = [_MET_VALUE[@"Run10mph"] floatValue];
    } else if (speedInMPH < 11.5) {
        METValue = [_MET_VALUE[@"Run11mph"] floatValue];
    } else if (speedInMPH < 12.5) {
        METValue = [_MET_VALUE[@"Run12mph"] floatValue];
    } else if (speedInMPH < 13.5) {
        METValue = [_MET_VALUE[@"Run13mph"] floatValue];
    } else {
        METValue = [_MET_VALUE[@"Run14mph"] floatValue];
    }
    _calories += _curUser_Weight * METValue * (float)curTime / 3600;
}

#pragma mark - MyLocationManager delegate
- (void)locationManager:(MyLocationManager *)locationManager routePoint:(CLLocation *)routePoint calculatedSpeed:(double)calculatedSpeed {
    _distance = [MyLocationManager shareLocationManager].totalDistance;
    _curSpeed = calculatedSpeed;
    if (calculatedSpeed > _maxSpeed) {
        _maxSpeed = calculatedSpeed;
    }
    
    [self calculateCalories:routePoint withSpeed:calculatedSpeed];
    //[self drawRoute];
    
    _lastLocation = [_routePoints lastObject];
    if ([_routePoints count] > 1) {
        [self drawRouteLine:_lastLocation.coordinate toCurrentLocation:routePoint.coordinate];
    }
    [_routePoints addObject:routePoint];
    [_locationDatatoStore addObject:[self locationToDictionary:routePoint withSpeed:[NSNumber numberWithDouble:calculatedSpeed]]];
    
    _endTime = routePoint.timestamp;
    
    _averageSpeed = _distance / [CommonFunctions getDuration:_startTime endTime:_endTime];
    
    [self displayInfoViews];
    
}

- (void)locationManager:(MyLocationManager *)locationManager locationUpdate:(CLLocation *)location {
    if (!_needUserLocation) {
        return;
    }
    MKCoordinateSpan span;
#warning change delta later
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    MKCoordinateRegion region;
    region.center = location.coordinate;
    region.span = span;
    [_mapView setRegion:region animated:YES];
    _needUserLocation = NO;
}

- (void)locationManager:(MyLocationManager *)locationManager startTimeStamp:(NSDate *)startTimeStamp {
    _startTime = startTimeStamp;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateDuration:) userInfo:nil repeats:YES];
}

- (void) updateDuration: (NSTimer*) theTimer {
    _lbInfo0.text = [CommonFunctions stringFromInterval:[CommonFunctions getDuration:_startTime endTime:[NSDate date]]];
}

- (void)locationManager:(MyLocationManager *)locationManager signalStrengthChanged:(GPSSignalStrength)signalStrength {
    switch (signalStrength) {
        case weak:
            _lbGPS.textColor = [UIColor redColor];
            break;
        case strong:
            _lbGPS.textColor = [UIColor greenColor];
            break;
            
        default:
            _lbGPS.textColor = [CommonFunctions grayColor];
            break;
    }
}

- (void)locationManagerSignalConsistentlyWeak:(MyLocationManager *)locationManager {
    //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Your GPS signal strength is consistantly weak." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    [CommonFunctions showStatusBarAlert:@"Your GPS signal strength is consistanctly weak" duration:2.0f backgroundColor:[UIColor redColor]];
}

- (void)locationManagerSignalInvalid:(MyLocationManager *)locationManager {
    //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please turn on your location service." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    
    [CommonFunctions showStatusBarAlert:@"Your GPS signal strength is consistanctly weak" duration:2.0f backgroundColor:[UIColor redColor]];
}

- (IBAction)showUserLocation:(id)sender {
    _needUserLocation = YES;
}

@end

























