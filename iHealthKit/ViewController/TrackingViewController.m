//
//  TrackingViewController.m
//  MMDrawerControllerKitchenSink
//
//  Created by admin on 7/17/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "TrackingViewController.h"
#import "MyVisualStateManager.h"
#import "RouteViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "View/RightImageCell.h"

#define VOICE_PITCH 1.49881518
#define VOICE_RATE 0.168246448
#define NOTIFY_DURATION_INTERVAL 300 //sec
#define NOTIFY_DISTANCE_INTERVAL 0.5

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
@property (weak, nonatomic) IBOutlet UIImageView *imgGPSSignal;
@property (weak, nonatomic) IBOutlet UIButton *btnStartStop;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *lbValue0;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription0;

@property (weak, nonatomic) IBOutlet UILabel *lbValue1;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription1;

@property (weak, nonatomic) IBOutlet UILabel *lbValue2;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription2;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

- (IBAction)minimizeMapView:(id)sender;
- (IBAction)btnClicked:(id)sender;
- (IBAction)showUserLocation:(id)sender;
- (IBAction)dismissTableView:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *listInfoTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnShowLocation;

@property (strong, nonatomic) NSArray* arrayLbDescription;
@property (strong, nonatomic) NSArray* arrayLbValue;

@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolylineView* routeView;

@property (nonatomic, strong) NSMutableArray* routePoints;
@property (nonatomic, strong) NSMutableArray* locationDatatoStore;
@property (nonatomic, strong) CLLocation* lastLocation;

@property (nonatomic) float calories;
@property (nonatomic) float distance;
@property (nonatomic) float curSpeed;
@property (nonatomic) float maxSpeed;
@property NSInteger trainingType;

@property float curUser_Weight;

@property (nonatomic) NSDate* startTime;
@property (nonatomic) NSDate* endTime;

@property (nonatomic, readonly) NSDictionary* MET_VALUE;

@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic) BOOL needUserLocation;

@property (strong, nonatomic) NSMutableArray* listInfoView;

@property BOOL isTableShowed;
@property NSInteger selectedLabelIndex;
@property UILabel* selectedLabel;

@property NSMutableArray* durationLabel;
@property NSMutableArray* clockLabel;

@property NSTimer* clockTimer;
@property NSTimer* durationTimer;

@property BOOL isVoiceTurnOn;
@property AVSpeechSynthesizer* mySynthesizer;
@property float notifyNextDistance;
@property int distanceType;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _curUser_Weight = [[[CoreDataFuntions curUser] weight] floatValue];
    
    [self setupBarButton];
    
    //[self setMetValueData];
    _MET_VALUE = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MetValue" ofType:@"plist"]];
    //[[NSBundle mainBundle] pathForResource:@"myPlist" ofType:@"plist"]] retain]
    
    [MyLocationManager shareLocationManager].delegate = self;
    [_mapView setDelegate:self];
    _mapView.showsUserLocation = YES;
    
    if (![[MyLocationManager shareLocationManager] prepLocationUpdates]) {
        [self locationManagerSignalInvalid:[MyLocationManager shareLocationManager]];
    }
    
    _needUserLocation = YES;
    _locationDatatoStore = [[NSMutableArray alloc] init];
    
    _durationLabel = [NSMutableArray new];
    _clockLabel = [NSMutableArray new];
    
    _listInfoView = [[NSMutableArray alloc] init];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_Duration]];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_Distance]];
    [_listInfoView addObject:[NSNumber numberWithInt:InfoType_Calories]];
    
    _listInfoTableView.frame = [self tableHiddenFrame];
    _listInfoTableView.delegate = self;
    _listInfoTableView.dataSource = self;
    [_listInfoTableView registerNib:[UINib nibWithNibName:@"RightImageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"rightImageCell"];
    [[_btnDone layer] setOpacity:0.0f];
    
    _isTableShowed = NO;
    
    [self addGestures];
    
    [self voiceCoachingChanged];
    _mySynthesizer = [[AVSpeechSynthesizer alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceCoachingChanged) name:@"VoiceCoachingChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:@"SettingChanged" object:nil];
    
    _arrayLbDescription = [NSArray arrayWithObjects:_lbDescription0, _lbDescription1, _lbDescription2, nil];
    _arrayLbValue = [NSArray arrayWithObjects:_lbValue0, _lbValue1, _lbValue2, nil];
    
    [self updateView];
}

- (void) updateView {
    [self updateDescription];
    [self updateValue];
    [self recalculateLastDistanceNotify];
}

- (void) voiceCoachingChanged {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VoiceCoaching"] == 1) {
        _isVoiceTurnOn = YES;
    } else {
        _isVoiceTurnOn = NO;
    }
}

- (void) updateValue {
    for (int i = 0; i < 3; i++) {
        NSInteger type = [[_listInfoView objectAtIndex:i] integerValue];
        UILabel* label = [_arrayLbValue objectAtIndex:i];
        NSString* valueStr = nil;
        switch (type) {
            case InfoType_Duration:
                if (![_durationLabel containsObject:label]) {
                    [_durationLabel addObject:label];
                }
                /*if (_durationLabel == nil || label != _durationLabel) {
                    _durationLabel = label;
                }*/
                break;
            case InfoType_Clock:
                if (![_clockLabel containsObject:label]) {
                    [_clockLabel addObject:label];
                }
                
                /*if (_clockLabel == nil || label != _clockLabel) {
                    _clockLabel = label;
                }*/
                break;
            case InfoType_AvgPace: {
                valueStr = [CommonFunctions paceStrFromSpeed:[self averageSpeed]];
                break;
            }
            case InfoType_AvgSpeed: {
                valueStr = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:[self averageSpeed]]];
                break;
            }
            case InfoType_Calories: {
                valueStr = [NSString stringWithFormat:@"%.2f", _calories];
                break;
            }
            case InfoType_CurPace: {
                valueStr = [CommonFunctions paceStrFromSpeed:_curSpeed];
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
            case InfoType_MaxSpeed: {
                valueStr = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:_maxSpeed]];
                break;
            }
            case InfoType_MaxPace: {
                valueStr = [CommonFunctions paceStrFromSpeed:_maxSpeed];
                break;
            }
            default:
                break;
        }
        
        if (valueStr) {
            label.text = valueStr;
        }
    }
}


- (void) updateDescription {
    for ( int i = 0; i < 3; i++) {
        NSInteger type = [[_listInfoView objectAtIndex:i] integerValue];
        UILabel* label = [_arrayLbDescription objectAtIndex:i];
        label.text = [self lbDescriptionStr:type];
    }
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
    
    _selectedLabel = (UILabel*)[(UIGestureRecognizer*)sender view];
    _selectedLabelIndex = [self selectedLabelIndex:_selectedLabel];
    [_listInfoTableView reloadData];
    [self blinkAnimation:_selectedLabel];
    
    _isTableShowed = YES;
}

- (void) changeSelectedView: (id) sender {
    if (!_isTableShowed || [(UIGestureRecognizer*)sender view] == _selectedLabel) {
        return;
    }
    
    [[_selectedLabel layer] removeAnimationForKey:@"opacity"];
    _selectedLabel = (UILabel*)[(UIGestureRecognizer*) sender view];
    _selectedLabelIndex = [self selectedLabelIndex:_selectedLabel];
    [self blinkAnimation:_selectedLabel];
    [_listInfoTableView reloadData];
}

- (NSInteger) selectedLabelIndex: (UILabel*) label {
    if (label == _lbValue0) {
        return 0;
    }
    if (label == _lbValue1) {
        return 1;
    }
    if (label == _lbValue2) {
        return 2;
    }
    return -1;
}

- (IBAction)dismissTableView:(id)sender {
    //[[_btnStartStop layer] setOpacity:0.0f];

    [UIView animateWithDuration:1.5f
                          delay:0.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _listInfoTableView.frame = [self tableHiddenFrame];
                         _listInfoTableView.layer.opacity = 0.0f;
                         [[_btnStartStop layer] setOpacity:1.0f];
                         [[_mapView layer] setOpacity:1.0f];
                         [[_btnShowLocation layer] setOpacity:1.0f];
                         [[_btnDone layer] setOpacity:0.0f];
                         [[_selectedLabel layer] removeAnimationForKey:@"opacity"];
                     }completion:nil];
    _isTableShowed = NO;
    _selectedLabel = nil;
    _selectedLabelIndex = -1;
}

- (void) blinkAnimation: (UIView*) view {
    CABasicAnimation *blinkAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [blinkAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
    [blinkAnimation setToValue:[NSNumber numberWithFloat:0.2]];
    [blinkAnimation setDuration:1.5f];
    [blinkAnimation setTimingFunction:[CAMediaTimingFunction
                                       functionWithName:kCAMediaTimingFunctionLinear]];
    [blinkAnimation setAutoreverses:YES];
    [blinkAnimation setRepeatCount:INT32_MAX];
    [[view layer] addAnimation:blinkAnimation forKey:@"opacity"];
}

- (CGRect) tableFrame {
    return CGRectMake(0, 307, 320, 220);
}
- (CGRect) tableHiddenFrame {
    return CGRectMake(0, 700, 320, 220);
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([CommonFunctions trackingStatus]) {
        [self stopTracking];
    }
}

- (void) maximizeMapView {
    CGRect mapViewFrame = self.view.frame;
    CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
    mapViewFrame.origin.y += navigationBarFrame.size.height + 20;
    mapViewFrame.size.height -= navigationBarFrame.size.height + _btnStartStop.frame.size.height + 20;
    
    [UIView animateWithDuration:2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _mapView.frame = mapViewFrame;
                         // _btnClose.hidden = NO;
                         _btnClose.layer.opacity = 1.0f;
                         //_lbDescription0.hidden = YES;
                         _lbDescription0.layer.opacity = 0.0f;
                         //_lbDescription1.hidden = YES;
                         _lbDescription1.layer.opacity = 0.0f;
                         //_lbDescription2.hidden = YES;
                         _lbDescription2.layer.opacity = 0.0f;
                         //_lbValue0.hidden = YES;
                         _lbValue0.layer.opacity = 0.0f;
                         //_lbValue1.hidden = YES;
                         _lbValue1.layer.opacity = 0.0f;
                         //_lbValue2.hidden = YES;
                         _lbValue2.layer.opacity = 0.0f;
                     } completion:nil];
}

- (IBAction)minimizeMapView:(id)sender {
    CGRect mapViewFrame = [self tableFrame];
    [UIView animateWithDuration:2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         _mapView.frame = mapViewFrame;
                         //_btnClose.hidden = YES;
                         _btnClose.layer.opacity = 0.0f;
                         //_lbDescription0.hidden = NO;
                         _lbDescription0.layer.opacity = 1.0f;
                         //_lbDescription1.hidden = NO;
                         _lbDescription1.layer.opacity = 1.0f;
                         //_lbDescription2.hidden = NO;
                         _lbDescription2.layer.opacity = 1.0f;
                         //_lbValue0.hidden = NO;
                         _lbValue0.layer.opacity = 1.0f;
                         //_lbValue1.hidden = NO;
                         _lbValue1.layer.opacity = 1.0f;
                         //_lbValue2.hidden = NO;
                         _lbValue2.layer.opacity = 1.0f;
                     } completion:nil];
}

-(void)setupBarButton{
    self.navigationItem.hidesBackButton = YES;
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:NO];
    
    UIBarButtonItem* rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:NO];
    
    
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress:(id) sender {
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
    if ([[MyLocationManager shareLocationManager] startLocationUpdates]) {
        [CommonFunctions showStatusBarAlert:@"Activity will start immediately after GPS signal is strong" duration:2.0f backgroundColor:[CommonFunctions yellowColor]];
        [self resetData];
        
        UILongPressGestureRecognizer* holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maximizeMapView)];
        [_mapView addGestureRecognizer:holdGesture];
        
        [_btnStartStop setTitle:@"Stop" forState:UIControlStateNormal];
        [_btnStartStop setBackgroundColor:[CommonFunctions redColor]];
        [CommonFunctions setTrackingStatus:YES];
    }
}

- (void) stopTracking {
    [_btnStartStop setTitle:@"Start" forState:UIControlStateNormal];
    [_btnStartStop setBackgroundColor:[CommonFunctions greenColor]];
    
    NSArray* overlays = [_mapView overlays];
    [_mapView removeOverlays:overlays];
    
    [CommonFunctions setTrackingStatus:NO];
    
    NSArray* listGesture = [_mapView gestureRecognizers];
    for (UIGestureRecognizer* gesture in listGesture) {
        [_mapView removeGestureRecognizer:gesture];
    }
    
    if (_startTime && _endTime) {
        if (_isVoiceTurnOn) {
            [self speak:@"Activity stopped"];
        }
        
        [[MyLocationManager shareLocationManager] stopLocationUpdates];
        [[MyLocationManager shareLocationManager] resetLocationUpdates];
        
        RouteViewController* routeVC = [[RouteViewController alloc] initNewRoute:_startTime endtime:_endTime distance:_distance maxSpeed:_maxSpeed averageSpeed:[self averageSpeed] trainingType:_trainingType calories:_calories locationData:_locationDatatoStore routePoints:_routePoints];
        
        [self.navigationController pushViewController:routeVC animated:YES];
    }
    
    else {
        if (_isVoiceTurnOn) {
            [self speak:@"Activity have not started yet."];
        }
        [self minimizeMapView:nil];
    }
    [self resetData];
}

- (void) resetData {
    _startTime = nil;
    _endTime = nil;
    _distance = 0.0f;
    _maxSpeed = 0.0f;
    _curSpeed = 0.0f;
    _trainingType = 0;
    _calories = 0.0f;
    
    [_clockTimer invalidate];
    _clockTimer = nil;
    [_durationTimer invalidate];
    _durationTimer = nil;
    
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
    if (!oldLocation) {
        return;
    }
    NSTimeInterval curTime = [newLocation.timestamp timeIntervalSinceNow] - [oldLocation.timestamp timeIntervalSinceNow];
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
- (void)locationManager:(MyLocationManager *)locationManager routePoint:(CLLocation *)routePoint curSpeed:(double)curSpeed {
    _distance = [MyLocationManager shareLocationManager].totalDistance;
    _curSpeed = (curSpeed >= 0) ? curSpeed : 0;
    if (_curSpeed > _maxSpeed) {
        _maxSpeed = _curSpeed;
    }
    
    [self calculateCalories:routePoint withSpeed:_curSpeed];
    //[self drawRoute];
    
    _lastLocation = [_routePoints lastObject];
    if ([_routePoints count] > 1) {
        [self drawRouteLine:_lastLocation.coordinate toCurrentLocation:routePoint.coordinate];
    }
    [_routePoints addObject:routePoint];
    [_locationDatatoStore addObject:[self locationToDictionary:routePoint withSpeed:[NSNumber numberWithDouble:_curSpeed]]];
    
    _endTime = routePoint.timestamp;
    
    [self updateValue];
    
    if (_isVoiceTurnOn) {
        [self distanceNotify];
    }
    
}

- (float) averageSpeed {
    return _distance / [CommonFunctions getDuration:_startTime endTime:_endTime];
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
    if (_isVoiceTurnOn) {
        [self speak:@"Activity started"];
        // add delay 0.5 sec before start the timer
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _durationTimer = [NSTimer scheduledTimerWithTimeInterval:NOTIFY_DURATION_INTERVAL target:self selector:@selector(durationNotify) userInfo:nil repeats:YES];
        });
    }
    if ([_clockLabel count] > 0  || [_durationLabel count] > 0) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
    }
}

- (void)locationManager:(MyLocationManager *)locationManager signalStrengthChanged:(GPSSignalStrength)signalStrength {
    switch (signalStrength) {
        case weak:
            [_imgGPSSignal setImage:[UIImage imageNamed:@"icon_signal_weak.png"]];
            break;
        case medium:
            [_imgGPSSignal setImage:[UIImage imageNamed:@"icon_signal_medium.png"]];
            break;
        case strong:
            [_imgGPSSignal setImage:[UIImage imageNamed:@"icon_signal_strong.png"]];
            break;
        default:
            [_imgGPSSignal setImage:[UIImage imageNamed:@"icon_signal_invalid.png"]];
            break;
    }
}

- (void)locationManagerSignalConsistentlyWeak:(MyLocationManager *)locationManager {
    //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Your GPS signal strength is consistantly weak." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    [CommonFunctions showStatusBarAlert:@"Your GPS signal strength is consistanctly weak" duration:2.0f backgroundColor:[CommonFunctions yellowColor]];
}

- (void)locationManagerSignalInvalid:(MyLocationManager *)locationManager {
    //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please turn on your location service." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    
    [CommonFunctions showStatusBarAlert:@"Please turn on the Location Services" duration:2.0f backgroundColor:[CommonFunctions redColor]];
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
    static NSString* CellIdentifier = @"rightImageCell";
    
    RightImageCell* cell = [self.listInfoTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RightImageCell alloc] init];
    }
    
    cell.lbUnitType.text = [self lbDescriptionStr:indexPath.row];
    int selectedRow = [[_listInfoView objectAtIndex:_selectedLabelIndex] integerValue];
    if (indexPath.row == selectedRow) {
        [cell.imgCheck setImage:[UIImage imageNamed:@"check_icon.png"]];
        //[self.listInfoTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    else {
        [cell.imgCheck setImage:[UIImage imageNamed:@"uncheck_icon.png"]];
    }
    
    return  cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[_listInfoView objectAtIndex:_selectedLabelIndex] integerValue] == InfoType_Clock) {
        [_clockLabel removeObject:_selectedLabel];
    }
    
    if ([[_listInfoView objectAtIndex:_selectedLabelIndex] integerValue] == InfoType_Duration) {
        [_durationLabel removeObject:_selectedLabel];
    }
    
    if ([_durationLabel count] == 0 && [_clockLabel count] == 0) {
        [_clockTimer invalidate];
        _clockTimer = nil;
    }
    
    [_listInfoView replaceObjectAtIndex:_selectedLabelIndex withObject:[NSNumber numberWithInt:indexPath.row]];
    [_listInfoTableView reloadData];
    
    [self updateDescription];
    [self updateValue];
    
    if (([_durationLabel count] > 0 || [_clockLabel count] > 0) && _clockTimer == nil && [CommonFunctions trackingStatus]) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
        [_clockTimer fire];
    }
    /*
    if (indexPath.row == InfoType_Duration) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
        [_clockTimer fire];
        
    }
    if (indexPath.row == InfoType_Clock) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
        [_clockTimer fire];
        
    }*/
}

- (void) updateClock {
    for (UILabel* label in _clockLabel) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (label == _lbValue0) {
            [dateFormatter setDateFormat:@"HH:mm:ss"];
        }
        else {
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        label.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    for (UILabel* label in _durationLabel) {
        if (_startTime) {
            if (label == _lbValue0) {
                label.text = [CommonFunctions stringSecondFromInterval:[CommonFunctions getDuration:_startTime endTime:[NSDate date]]];
                
            }
            else {
                label.text = [CommonFunctions stringMinuteFromInterval:[CommonFunctions getDuration:_startTime endTime:[NSDate date]]];
            }
        }
        else {
            if (label == _lbValue0) {
                label.text = @"00:00:00";
                
            }
            else {
                label.text = @"00:00";
            }
        }
    }
    /*if (_clockLabel) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (_clockLabel == _lbValue0) {
            [dateFormatter setDateFormat:@"HH:mm:ss"];
        }
        else {
            
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        _clockLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    if (_durationLabel) {
        if (_startTime) {
            if (_durationLabel == _lbValue0) {
                _durationLabel.text = [CommonFunctions stringSecondFromInterval:[CommonFunctions getDuration:_startTime endTime:[NSDate date]]];
                
            }
            else {
                _durationLabel.text = [CommonFunctions stringMinuteFromInterval:[CommonFunctions getDuration:_startTime endTime:[NSDate date]]];
            }
        }
        else {
            if (_durationLabel == _lbValue0) {
                _durationLabel.text = @"00:00:00";
                
            }
            else {
                _durationLabel.text = @"00:00";
            }
        }
    }*/
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
          descriptionStr = [NSString stringWithFormat:@"Current Pace (%@)", [CommonFunctions getPaceUnitString]];
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
       descriptionStr = [NSString stringWithFormat:@"Maximum Pace (%@)", [CommonFunctions getPaceUnitString]];
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
            valueStr = [CommonFunctions paceStrFromSpeed:[self averageSpeed]];
            break;
        }
        case InfoType_AvgSpeed: {
            valueStr = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:[self averageSpeed]]];
            break;
        }
        case InfoType_Calories: {
            valueStr = [NSString stringWithFormat:@"%.2f", _calories];
            break;
        }
        case InfoType_Clock: {
            //valueStr = @"00:00";
            break;
        }
        case InfoType_CurPace: {
            valueStr = [CommonFunctions paceStrFromSpeed:_curSpeed];
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
            valueStr = [CommonFunctions paceStrFromSpeed:_maxSpeed];
            break;
        }
        default:
            break;
    }
    return valueStr;
}

- (void) setMetValueData {
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
    
}

- (void) addGestures {
    [self addHoldGesture:_lbValue0];
    [self addHoldGesture:_lbValue1];
    [self addHoldGesture:_lbValue2];
    
    [self addTapGesture:_lbValue0];
    [self addTapGesture:_lbValue1];
    [self addTapGesture:_lbValue2];
}

- (void) addHoldGesture: (UIView*) view {
    UILongPressGestureRecognizer* holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(displayListViewTable:)];
    [view addGestureRecognizer:holdGesture];
}
- (void) addTapGesture: (UIView*) view {
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSelectedView:)];
    [view addGestureRecognizer:tapGesture];
}

#pragma mark - voice coaching
- (void) speak: (NSString*) text {
    AVSpeechUtterance* speechUtterance = [[AVSpeechUtterance alloc] initWithString:text];
    speechUtterance.pitchMultiplier = VOICE_PITCH;
    speechUtterance.rate = VOICE_RATE;
    [_mySynthesizer speakUtterance:speechUtterance];
}

- (void) durationNotify {
    NSTimeInterval duration = [CommonFunctions getDuration:_startTime endTime:[NSDate date]];
    NSString* durationString = [NSString stringWithFormat:@"Duration %d hours and %d minutes", [CommonFunctions timePart:duration withPart:DatePartType_hour], [CommonFunctions timePart:duration withPart:DatePartType_minute]];
    [self speak:durationString];
}

- (void) distanceNotify {
    int distanceType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DistanceType"] integerValue];
    
    if (distanceType == 1) {
        if ([CommonFunctions convertDistanceToMile:_distance] >= _notifyNextDistance) {
            [self speak:[NSString stringWithFormat:@"Distance %1f miles", _notifyNextDistance]];
            _notifyNextDistance += NOTIFY_DISTANCE_INTERVAL;
        }
    } else {
        if ([CommonFunctions convertDistanceToKm:_distance] >= _notifyNextDistance) {
        [self speak:[NSString stringWithFormat:@"Distance %.1f kilometers", _notifyNextDistance]];
        _notifyNextDistance += NOTIFY_DISTANCE_INTERVAL;
        }
    }
}

- (void) recalculateLastDistanceNotify {
    _notifyNextDistance = 0.0;
    _distanceType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DistanceType"] integerValue];
    float convertedDistance = (_distanceType == 1) ? [CommonFunctions convertDistanceToMile:_distance] : [CommonFunctions convertDistanceToKm:_distance];
    
    do {
        _notifyNextDistance += NOTIFY_DISTANCE_INTERVAL;
    } while (_notifyNextDistance < convertedDistance);
}

@end























