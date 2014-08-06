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
@property (weak, nonatomic) IBOutlet UIButton *btnShowLocation;

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

@property (nonatomic, readonly) NSMutableDictionary* MET_VALUE;

@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic) BOOL needUserLocation;

@property (strong, nonatomic) NSMutableArray* listInfoView;

@property BOOL isTableShowed;
@property NSInteger selectedIndex;
@property UILabel* selectedLabel;

@property UILabel* durationLabel;
@property UILabel* clockLabel;
@property NSTimer* durationTimer;
@property NSTimer* clockTimer;

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
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_Distance]];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_Calories]];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_AvgSpeed]];
    _durationLabel = nil;
    _clockLabel = nil;
    
    _listInfoTableView.frame = [self tableHiddenFrame];
    _listInfoTableView.hidden = YES;
    _listInfoTableView.delegate = self;
    _listInfoTableView.dataSource = self;
    [[_btnDone layer] setOpacity:0.0f];
    
    _btnClose.hidden = YES;
    
    _isTableShowed = NO;
    
    [self addHoldGesture:_lbInfo0];
    [self addHoldGesture:_lbInfo1];
    [self addHoldGesture:_lbInfo2];
    
    [self addTapGesture:_lbInfo0];
    [self addTapGesture:_lbInfo1];
    [self addTapGesture:_lbInfo2];

    //[self resetData];
    [self updateValue];
    [self updateDescription];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self stopTracking];
    [_lbInfo0 setUserInteractionEnabled:NO];
    [_lbInfo1 setUserInteractionEnabled:NO];
    [_lbInfo2 setUserInteractionEnabled:NO];
}

- (void) addHoldGesture: (UIView*) view {
    UILongPressGestureRecognizer* holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(displayListViewTable:)];
    [view addGestureRecognizer:holdGesture];
}
- (void) addTapGesture: (UIView*) view {
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSelectedView:)];
    [view addGestureRecognizer:tapGesture];
}

- (void) updateValue {
    NSInteger type = [[_listInfoView objectAtIndex:0] integerValue];
    if (type != InfoType_Duration && type != InfoType_Clock) {
        _lbInfo0.text = [self lbValueStr:[[_listInfoView objectAtIndex:0] integerValue]];
    }
    
    type = [[_listInfoView objectAtIndex:1] integerValue];
    if (type != InfoType_Duration && type != InfoType_Clock) {
        _lbInfo1.text = [self lbValueStr:[[_listInfoView objectAtIndex:1] integerValue]];
    }
    
    type = [[_listInfoView objectAtIndex:2] integerValue];
    if (type != InfoType_Duration && type != InfoType_Clock) {
        _lbInfo2.text = [self lbValueStr:[[_listInfoView objectAtIndex:2] integerValue]];
    }
}

- (void) updateDescription {
    _lbDescription0.text = [self lbDescriptionStr:[[_listInfoView objectAtIndex:0] integerValue]];
    _lbDescription1.text = [self lbDescriptionStr:[[_listInfoView objectAtIndex:1] integerValue]];
    _lbDescription2.text = [self lbDescriptionStr:[[_listInfoView objectAtIndex:2] integerValue]];
}

- (void) displayListViewTable: (id) sender{
    if (_isTableShowed) {
        return;
    }
    _listInfoTableView.frame = [self tableHiddenFrame];
    _listInfoTableView.hidden = NO;

    [UIView animateWithDuration:1.5f
                          delay:0.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _listInfoTableView.frame = [self tableFrame];
                         [[_btnStartStop layer] setOpacity:0.0f];
                         [[_mapView layer] setOpacity:0.0f];
                         [[_btnShowLocation layer] setOpacity:0.0f];
                         [[_btnDone layer] setOpacity:1.0f];
                     }completion:nil];
    
    [CommonFunctions showStatusBarAlert:@"Timer stated" duration:2.5f backgroundColor:[UIColor blackColor]];

    _selectedLabel = (UILabel*)[(UIGestureRecognizer*)sender view];
    _selectedIndex = [self getSelectedIndex:_selectedLabel];
    [self blinkAnimation:_selectedLabel];
    
    _isTableShowed = YES;
}

- (void) changeSelectedView: (id) sender {
    if (!_isTableShowed || [(UIGestureRecognizer*)sender view] == _selectedLabel) {
        return;
    }
    
    [[_selectedLabel layer] removeAllAnimations];
    _selectedLabel = (UILabel*)[(UIGestureRecognizer*) sender view];
    _selectedIndex = [self getSelectedIndex:_selectedLabel];
    [self blinkAnimation:_selectedLabel];
    [_listInfoTableView reloadData];
}

- (NSInteger) getSelectedIndex: (UILabel*) label {
    NSInteger index = -1;
    if (label == _lbInfo0) {
        index = 0;
    }
    if (label == _lbInfo1) {
        index = 1;
    }
    if (label == _lbInfo2) {
        index = 2;
    }
    return index;
}

- (IBAction)dismissTableView:(id)sender {
    //[[_btnStartStop layer] setOpacity:0.0f];

    [UIView animateWithDuration:1.5f
                          delay:0.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _listInfoTableView.frame = [self tableHiddenFrame];
                         [[_btnStartStop layer] setOpacity:1.0f];
                         [[_mapView layer] setOpacity:1.0f];
                         [[_btnShowLocation layer] setOpacity:1.0f];
                         [[_btnDone layer] setOpacity:0.0f];
                         [[_selectedLabel layer] removeAllAnimations];
                     }completion:^(BOOL finished){
                         _listInfoTableView.hidden = YES;
                         
                     }];
    _isTableShowed = NO;
    _selectedLabel = nil;
    _selectedIndex = -1;
}

- (void) blinkAnimation: (UIView*) view {
    CABasicAnimation *blinkAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [blinkAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
    [blinkAnimation setToValue:[NSNumber numberWithFloat:0.2]];
    [blinkAnimation setDuration:1.5f];
    [blinkAnimation setTimingFunction:[CAMediaTimingFunction
                                       functionWithName:kCAMediaTimingFunctionLinear]];
    [blinkAnimation setAutoreverses:YES];
    [blinkAnimation setRepeatCount:500000];
    [[view layer] addAnimation:blinkAnimation forKey:@"opacity"];
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
        [_lbInfo0 setUserInteractionEnabled:YES];
        [_lbInfo1 setUserInteractionEnabled:YES];
        [_lbInfo2 setUserInteractionEnabled:YES];
        [self startTracking];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self stopTracking];
            [_lbInfo0 setUserInteractionEnabled:NO];
            [_lbInfo1 setUserInteractionEnabled:NO];
            [_lbInfo2 setUserInteractionEnabled:NO];
            break;
        default:
            break;
    }
}

- (void) startTracking {
    [self resetData];
    [[MyLocationManager shareLocationManager] startLocationUpdates];
    
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
    [self resetData];
    
}

- (void) resetData {
    _startTime = nil;
    _endTime = nil;
    _distance = 0.0f;
    _maxSpeed = 0.0f;
    _curSpeed = 0.0f;
    _averageSpeed = 0.0f;
    _trainingType = 0;
    _calories = 0.0f;
    
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
    
    [self updateValue];
    
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
    
    if (indexPath.row == [[_listInfoView objectAtIndex:_selectedIndex] integerValue]) {
        [cell.rightImage setImage:[UIImage imageNamed:@"check_icon.png"]];
        //[self.listInfoTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    else {
        [cell.rightImage setImage:[UIImage imageNamed:@"uncheck_icon.png"]];
    }
    
    return  cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[_listInfoView objectAtIndex:_selectedIndex] integerValue] == InfoType_Clock) {
        _clockLabel = nil;
    }
    if ([[_listInfoView objectAtIndex:_selectedIndex] integerValue] == InfoType_Duration) {
        _durationLabel = nil;
    }
    if (_durationLabel == nil || _clockLabel == nil) {
        [_clockTimer invalidate];
    }
    
    [_listInfoView replaceObjectAtIndex:_selectedIndex withObject:[NSNumber numberWithInt:indexPath.row]];
    [_listInfoTableView reloadData];
    
    [self updateDescription];
    [self updateValue];
    
    if (indexPath.row == InfoType_Duration) {
        _durationLabel = _selectedLabel;
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
        
    }
    if (indexPath.row == InfoType_Clock) {
        _clockLabel = _selectedLabel;
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
        
    }
}

- (void) updateClock {
    if (_clockLabel) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (_clockLabel == _lbInfo0) {
            
            [dateFormatter setDateFormat:@"HH:mm:ss"];
        }
        else {
            
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        _clockLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    if (_durationLabel) {
        if (_durationLabel == _lbInfo0) {
            _durationLabel.text = [CommonFunctions stringSecondFromInterval:[CommonFunctions getDuration:_startTime endTime:[NSDate date]]];

        }
        else {
            _durationLabel.text = [CommonFunctions stringMinuteFromInterval:[CommonFunctions getDuration:_startTime endTime:[NSDate date]]];

        }
    }
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
            if (_calories != 0.0f) {
                valueStr = [NSString stringWithFormat:@"%.2f", _calories];
            }
            else {
                valueStr = @"0.00";
            }
            break;
        }
        case InfoType_Clock: {
            //valueStr = @"00:00";
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
            //valueStr = @"00:00:00";
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

























