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
#import "View/CellWithRightImage.h"

typedef enum {
    InfoType_Duration,
    InfoType_Distance,
    InfoType_AvgSpeed,
    InfoType_CurSpeed,
    InfoType_MaxSpeed,
    InfoType_AvgPace,
    InfoType_CurPace,
    InfoType_MaxPace,
    InfoType_Calories,
    InfoType_Clock
} InfoType;

@interface TrackingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbGPS;
@property (weak, nonatomic) IBOutlet UIButton *btnStartStop;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *lbInfo0;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription0;

@property (weak, nonatomic) IBOutlet UILabel *lbInfo1;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription1;

@property (weak, nonatomic) IBOutlet UILabel *lbInfo2;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription2;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

- (IBAction)minimizeMapView:(id)sender;
- (IBAction)btnClicked:(id)sender;
- (IBAction)showUserLocation:(id)sender;
- (IBAction)dismissTableView:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *listInfoTableView;

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

@property (strong, nonatomic) NSMutableArray* listInfoView;

@property NSInteger selectedLabel;

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
    
    _listInfoView = [[NSMutableArray alloc] init];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_Duration]];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_Distance]];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_AvgSpeed]];
    
    _listInfoTableView.frame = [self tableHiddenFrame];
    _listInfoTableView.hidden = YES;
    _listInfoTableView.delegate = self;
    _listInfoTableView.dataSource = self;
    _btnDone.hidden = YES;
    
    _btnClose.hidden = YES;
    
    UILongPressGestureRecognizer* holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeViewSettings)];
    [_lbInfo0 addGestureRecognizer:holdGesture];
    [_lbInfo0 setUserInteractionEnabled:YES];
    //[self resetData];
    [self displayInfoViews];
}

- (void) displayInfoViews {
    [self displayInfo:[[_listInfoView objectAtIndex:0] integerValue] withLbDescription:_lbDescription0 withLbValue:_lbInfo0];
    [self displayInfo:[[_listInfoView objectAtIndex:1] integerValue] withLbDescription:_lbDescription1 withLbValue:_lbInfo1];
    [self displayInfo:[[_listInfoView objectAtIndex:2] integerValue] withLbDescription:_lbDescription2 withLbValue:_lbInfo2];
}

- (void) changeViewSettings {
    _listInfoTableView.frame = [self tableHiddenFrame];
    _listInfoTableView.hidden = NO;
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _listInfoTableView.frame = [self tableFrame];
                     }completion:nil];
    
    [UIView animateWithDuration:0.5f
                          delay:1.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _btnDone.hidden = NO;
                         _btnStartStop.hidden = YES;
                         _mapView.hidden = YES;
                     }completion:nil];
    
    [CommonFunctions showStatusBarAlert:@"Timer stated" duration:2.5f backgroundColor:[UIColor blackColor]];
    [UIView animateWithDuration:1.5
                          delay:0.5
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         _lbInfo0.alpha = 0.2f;
                     } completion:nil];
    
}

- (IBAction)dismissTableView:(id)sender {
    _btnStartStop.hidden = NO;
    _mapView.hidden = NO;
    [_timer invalidate];
    
    [UIView animateWithDuration:2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{                         _listInfoTableView.frame = [self tableFrame];
                         _btnDone.hidden = NO;
                         _btnStartStop.hidden = YES;
                         _mapView.hidden = YES;
                     }completion:^(BOOL finished){
                         _listInfoTableView.hidden = NO;
                     }];
    
}

- (void) animateBlink {
    
}

- (void) displayInfo: (NSInteger) type withLbDescription:(UILabel*) description withLbValue: (UILabel*) value {
    description.text = [self lbDescriptionStr:type];
    value.text = [self lbValueStr:type];
    
}

- (CGRect) tableFrame {
    return CGRectMake(0, 307, 320, 220);
}
- (CGRect) tableHiddenFrame {
    return CGRectMake(0, 700, 320, 220);
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([CommonFunctions getTrackingStatus]) {
        [self stopTracking];
    }
}

- (void) maximizeMapView {
    CGRect mapViewFrame = self.view.frame;
    
    [UIView animateWithDuration:2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _btnClose.hidden = NO;
                         _lbDescription0.hidden = YES;
                         _lbDescription1.hidden = YES;
                         _lbDescription2.hidden = YES;
                         _lbInfo0.hidden = YES;
                         _lbInfo1.hidden = YES;
                         _lbInfo2.hidden = YES;
                         _mapView.frame = mapViewFrame;
                     } completion:nil];
}

- (IBAction)minimizeMapView:(id)sender {
    CGRect mapViewFrame = [self tableFrame];
    [UIView animateWithDuration:2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _mapView.frame = mapViewFrame;
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5f
                                               delay:0.0f
                                             options:UIViewAnimationOptionShowHideTransitionViews
                                          animations:^{
                                              _btnClose.hidden = YES;
                                              _lbDescription0.hidden = NO;
                                              _lbDescription1.hidden = NO;
                                              _lbDescription2.hidden = NO;
                                              _lbInfo0.hidden = NO;
                                              _lbInfo1.hidden = NO;
                                              _lbInfo2.hidden = NO;
                                          }completion:nil];
                     }];
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
    
    UILongPressGestureRecognizer* holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maximizeMapView)];
    [_mapView addGestureRecognizer:holdGesture];
    
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
    
    NSArray* listGesture = [_mapView gestureRecognizers];
    for (UIGestureRecognizer* gesture in listGesture) {
        [_mapView removeGestureRecognizer:gesture];
    }
    
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


#pragma mark - table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"cell";
    
    CellWithRightImage* cell = [self.listInfoTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CellWithRightImage alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    cell.textLabel.text = [self lbDescriptionStr:indexPath.row];
    
    if (indexPath.row == [[_listInfoView objectAtIndex:_selectedLabel] integerValue]) {
        [cell.rightImage setImage:[UIImage imageNamed:@"check_icon.png"]];
        //[self.listInfoTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    else {
        [cell.rightImage setImage:[UIImage imageNamed:@"uncheck_icon.png"]];
    }
    
    return  cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_listInfoView replaceObjectAtIndex:_selectedLabel withObject:[NSNumber numberWithInt:indexPath.row]];
    [self displayInfoViews];
}

- (NSString*) lbDescriptionStr: (NSInteger) type {
    NSString* descriptionStr = @"";
    switch (type) {
        case InfoType_AvgPace: {
            descriptionStr = [NSString stringWithFormat:@"Average Pace (%@)", [CommonFunctions getPaceUnitString]];
            break;
        }
        case InfoType_AvgSpeed: {
           descriptionStr = [NSString stringWithFormat:@"Average Speed (%@)", [CommonFunctions getVelocityUnitString]];
            break;
        }
        case InfoType_Calories: {
         descriptionStr = @"Calories";
            break;
        }
        case InfoType_Clock: {
         descriptionStr = @"Clock";
            break;
        }
        case InfoType_CurPace: {
          descriptionStr = @"Current Pace";
            break;
        }
        case InfoType_CurSpeed: {
         descriptionStr =  [NSString stringWithFormat:@"Current Speed (%@)", [CommonFunctions getVelocityUnitString]];
            break;
        }
        case InfoType_Distance: {
          descriptionStr = [NSString stringWithFormat:@"Distance (%@)", [CommonFunctions getDistanceUnitString]];
            break;
        }
        case InfoType_Duration: {
            descriptionStr = @"Duration";
            break;
        }
        case InfoType_MaxSpeed: {
          descriptionStr = [NSString stringWithFormat:@"Maximum Speed (%@)", [CommonFunctions getVelocityUnitString]];
            break;
        }
        case InfoType_MaxPace: {
       descriptionStr = @"Maximum Pace";
            break;
        }
        default:
            break;
    }
    return descriptionStr;
}

- (NSString*) lbValueStr: (NSInteger) type {
    NSString* valueStr = @"";
    switch (type) {
        case InfoType_AvgPace: {
            valueStr = [CommonFunctions convertPace:_averageSpeed];
            break;
        }
        case InfoType_AvgSpeed: {
            valueStr = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:_averageSpeed]];
            break;
        }
        case InfoType_Calories: {
            valueStr = [NSString stringWithFormat:@"%.2f", _calories];
            break;
        }
        case InfoType_Clock: {
            valueStr = @"00:00";
            break;
        }
        case InfoType_CurPace: {
            valueStr = [CommonFunctions convertPace:_curSpeed];
            break;
        }
        case InfoType_CurSpeed: {
            valueStr =  [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:_curSpeed]];
            break;
        }
        case InfoType_Distance: {
            valueStr = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertDistance:_distance]];
            break;
        }
        case InfoType_Duration: {
            valueStr = @"00:00:00";
            break;
        }
        case InfoType_MaxSpeed: {
            valueStr = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:_maxSpeed]];
            break;
        }
        case InfoType_MaxPace: {
            valueStr = [CommonFunctions convertPace:_maxSpeed];
            break;
        }
        default:
            break;
    }
    return valueStr;
}

@end

























