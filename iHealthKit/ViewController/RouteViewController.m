//
//  RouteViewController.m
//  iHealthKit
//
//  Created by admin on 7/19/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "RouteViewController.h"
#import "TrackingViewController.h"
#import "View/RouteOverviewCell.h"
#import "View/RouteDetailCell.h"
#import "View/RouteAnnotationView.h"

typedef enum  {
    RowType_StartTime = 0,
    RowType_EndTime,
    RowType_AvgSpeed,
    RowType_MaxSpeed,
    RowType_AvgPace,
    RowType_MaxPace
} RowType;

@interface RouteViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)minimizeMapView:(id)sender;

@property (nonatomic, strong) MyRoute* route;

@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolylineView* routeView;

@property (nonatomic, strong) NSMutableArray* routePoints;
@property (nonatomic, strong) NSMutableArray* locationDatatoStore;

@property (nonatomic) float calories;
@property (nonatomic) float distance;
@property (nonatomic) float maxSpeed;
@property (nonatomic) float averageSpeed;

@property (nonatomic) NSDate* startTime;
@property (nonatomic) NSDate* endTime;
@property NSInteger trainingType;

@property (nonatomic) CLLocationCoordinate2D northEastPoint;
@property (nonatomic) CLLocationCoordinate2D southWestPoint;
@property (nonatomic) BOOL canDelete;
@property NSInteger unit;
@property (nonatomic) NSTimeInterval duration;

@end

@implementation RouteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initwithRoute:(MyRoute *)route {
    
    RouteViewController* newRouteVC = [[RouteViewController alloc] init];
    newRouteVC.distance = [route.distance floatValue];
    newRouteVC.startTime = route.startTime;
    newRouteVC.endTime = route.endTime;
    newRouteVC.calories = [route.calories floatValue];
    newRouteVC.maxSpeed = [route.maxSpeed floatValue];
    newRouteVC.routePoints = [[NSMutableArray alloc] init];
    newRouteVC.route = route;
    newRouteVC.averageSpeed = [route.avgSpeed floatValue];
    NSError* error = nil;
    NSArray* readLocations = [NSJSONSerialization JSONObjectWithData:route.routePoints options:NSJSONReadingAllowFragments error:&error];
    
    for (int i = 0; i < readLocations.count; ++i) {
        NSDictionary* loc = [readLocations objectAtIndex:i];
        CLLocation* newLoc = [[CLLocation alloc] initWithLatitude:[loc[@"latitude"] floatValue] longitude:[loc[@"longitude"] floatValue]];
        [newRouteVC.routePoints addObject:newLoc];
    }
    newRouteVC.canDelete = TRUE;
    
    return newRouteVC;
}

-(id) initNewRoute: (NSDate*) startTime endtime:(NSDate*)endTime distance:(float)distance maxSpeed:(float)maxSpeed averageSpeed:(float) avgSpeed trainingType:(int)trainingType calories:(float) calories locationData:(NSMutableArray*) locationData routePoints:(NSMutableArray*) routePoints{
    RouteViewController* routeVC = [[RouteViewController alloc] init];
    routeVC.startTime = startTime;
    routeVC.endTime = endTime;
    routeVC.distance = distance;
    routeVC.maxSpeed = maxSpeed;
    routeVC.trainingType = trainingType;
    routeVC.averageSpeed = avgSpeed;
    routeVC.calories = calories;
    routeVC.locationDatatoStore = [[NSMutableArray alloc] initWithArray:locationData copyItems:YES];
    routeVC.routePoints = [[NSMutableArray alloc] initWithArray:routePoints copyItems:YES];

    return routeVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _duration = [CommonFunctions getDuration:_startTime endTime:_endTime];
    
    [self setupBarButton];
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.tableView registerNib:[UINib nibWithNibName:@"RouteDetailCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"routeDetailCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RouteOverviewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"routeHeaderCell"];
    
    [_mapView setDelegate:self];
    [_mapView showsUserLocation];
    
    _btnClose.hidden = YES;
    
    UILongPressGestureRecognizer* holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maximizeMapView)];
    [_mapView addGestureRecognizer:holdGesture];
    
    [self drawRoute];
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 6;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if (indexPath.section == 0) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"routeHeaderCell"];
        if (cell == nil) {
            cell = [[RouteOverviewCell alloc] init];
        }
        
    }
    else {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"routeDetailCell"];
        if (cell == nil) {
            cell = [[RouteDetailCell alloc] init];
        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell: (UITableViewCell*) cell atIndexPath: (NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        RouteOverviewCell* headerCell = (RouteOverviewCell*) cell;
        headerCell.lbCalories.text = [NSString stringWithFormat:@"%.0f", _calories];
        headerCell.lbDistance.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertDistance:_distance]];
        
        headerCell.lbDistanceUnit.text = [NSString stringWithFormat:@"Distance (%@)", [CommonFunctions getDistanceUnitString]];
        headerCell.lbDistance.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertDistance:_distance]];
        headerCell.lbDuration.text = [CommonFunctions stringSecondFromInterval:_duration];
    }
    
    else {
        RouteDetailCell* detailCell = (RouteDetailCell*) cell;
        
        switch (indexPath.row) {
            case RowType_AvgPace: {
                detailCell.lbDescription.text = @"Average Pace";
                detailCell.lbDetail.text = [CommonFunctions paceStrFromSpeed:_averageSpeed];
                detailCell.imgView.image = [UIImage imageNamed:@"icon_paceAvg.png"];
                break;
            }
            case RowType_MaxPace: {
                detailCell.lbDescription.text = @"Max. Pace";
                detailCell.lbDetail.text = [CommonFunctions paceStrFromSpeed:_averageSpeed];
                detailCell.imgView.image = [UIImage imageNamed:@"icon_paceMax.png"];
                break;
            }
            case RowType_AvgSpeed: {
                detailCell.lbDescription.text = @"Average Speed";
                float avgSpeed = [CommonFunctions convertSpeed:_averageSpeed];
                detailCell.lbDetail.text = [NSString stringWithFormat:@"%.2f", avgSpeed];
                detailCell.imgView.image = [UIImage imageNamed:@"icon_speedAvg.png"];
                break;
            }
            case RowType_EndTime: {
                detailCell.lbDescription.text = @"End Time";
                detailCell.lbDetail.text = [NSDateFormatter localizedStringFromDate:_endTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                detailCell.imgView.image = [UIImage imageNamed:@"icon_timeStop.png"];
                break;
            }
            case RowType_MaxSpeed: {
                detailCell.lbDescription.text = @"Max. Speed";
                detailCell.lbDetail.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:_maxSpeed]];
                detailCell.imgView.image = [UIImage imageNamed:@"icon_speedMax.png"];
                break;
            }
            case RowType_StartTime: {
                detailCell.lbDescription.text = @"Start Time";
                detailCell.lbDetail.text = [NSDateFormatter localizedStringFromDate:_startTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                detailCell.imgView.image = [UIImage imageNamed:@"icon_timeStart.png"];
                break;
            }
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 64;
    }
    else
        return 36;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 20;
    }
    return 0;
}

#pragma mark - mapview delegate
- (MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKOverlayView* overlayView = nil;
	
	if(overlay == _routeLine)
	{
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

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[RouteAnnotationView class]])
    {
        RouteAnnotationView *routeAnnotation = (RouteAnnotationView*) annotation;
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            //pinView.animatesDrop = YES;
            //pinView.image = [UIImage imageNamed:@"pizza_slice_32.png"];
            pinView.calloutOffset = CGPointMake(0, 20);
        } else {
            pinView.annotation = annotation;
        }
        if (routeAnnotation.type == AnnotationType_Start) {
            pinView.image = [UIImage imageNamed:@"annotation_start20.png"];
        }
        else {
            pinView.image = [UIImage imageNamed:@"annotation_finished20.png"];
        }
        
        return pinView;
    }
    return nil;
}

- (void) drawRoute {
    if ([_routePoints count] < 3) {
        return;
    }
    
    MKMapPoint* mapPoints = malloc(sizeof(CLLocationCoordinate2D) * _routePoints.count);
    
    for (int i = 0; i < _routePoints.count; ++i ) {
        CLLocation* loc = [_routePoints objectAtIndex:i];
        
        if (i == 0) {
            _northEastPoint = loc.coordinate;
            _southWestPoint = loc.coordinate;
            RouteAnnotationView* startPoint = [[RouteAnnotationView alloc] initWithCoordinate:loc.coordinate type:AnnotationType_Start];
            [_mapView addAnnotation:startPoint];
        }
        else {
            if (i == _routePoints.count - 1) {
                _northEastPoint = loc.coordinate;
                _southWestPoint = loc.coordinate;
                RouteAnnotationView* endPoint = [[RouteAnnotationView alloc] initWithCoordinate:loc.coordinate type:AnnotationType_Stop];
                [_mapView addAnnotation:endPoint];
            }
            if (loc.coordinate.latitude > _northEastPoint.latitude) {
                _northEastPoint.latitude = loc.coordinate.latitude ;
            }
            if (loc.coordinate.longitude > _northEastPoint.longitude) {
                _northEastPoint.longitude = loc.coordinate.longitude ;
            }
            if (loc.coordinate.latitude < _southWestPoint.latitude)
				_southWestPoint.latitude = loc.coordinate.latitude;
			if (loc.coordinate.longitude < _southWestPoint.longitude)
				_southWestPoint.longitude = loc.coordinate.longitude;
        }
        
        mapPoints[i] = MKMapPointForCoordinate(loc.coordinate);
    }

    if (_routeLine != nil) {
        [_mapView removeOverlay:_routeLine];
    }
    _routeLine = [MKPolyline polylineWithPoints:mapPoints count:_routePoints.count];
    [_mapView addOverlay:_routeLine];
    
    CLLocationDegrees latitudeDelta = _northEastPoint.latitude - _southWestPoint.latitude;
    CLLocationDegrees longitudeDelta = _northEastPoint.longitude - _southWestPoint.longitude;
    MKCoordinateSpan span;
    span.latitudeDelta = (latitudeDelta > 0.004) ? latitudeDelta : 0.004;;
    span.longitudeDelta = (longitudeDelta > 0.004) ? longitudeDelta : 0.004;;
    MKCoordinateRegion region;
    region.center.latitude = _southWestPoint.latitude + ((_northEastPoint.latitude - _southWestPoint.latitude) / 2);
    region.center.longitude = _southWestPoint.longitude + ((_northEastPoint.longitude - _southWestPoint.longitude) / 2);
    region.span = span;
    [_mapView setRegion:region animated:YES];
    
}

#pragma mark - route function
- (void) saveRoutetoCoreData {
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:_locationDatatoStore options:NSJSONWritingPrettyPrinted error:&error];
    if (error == nil) {
        NSLog(@"%@", jsonData);
    }
    else {
        NSLog(@"error: %@", error);
        return;
    }
    float avgSpeed = _distance / _duration;
    [CoreDataFuntions saveNewRoute:_startTime endTime:_endTime calories:_calories maxSpeed:_maxSpeed avgSpeed:avgSpeed distance:_distance locations:jsonData mood:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EditUser" object:self];
    
    [CommonFunctions showStatusBarAlert:@"New route has been added to your history." duration:3.0f backgroundColor: [CommonFunctions greenColor]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserInfoChanged" object:nil];
    TrackingViewController* trackVC = [[TrackingViewController alloc] init];
    [self.navigationController pushViewController:trackVC animated:YES];
}

- (void) deleteRoute {
#warning alert
    [CoreDataFuntions deleteRoute:_route];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HistoryChanged" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) discardRoute {
    [CommonFunctions showStatusBarAlert:@"Route has been discarded." duration:3.0f backgroundColor: [CommonFunctions redColor]];
    TrackingViewController* trackVC = [[TrackingViewController alloc] init];
    [self.navigationController pushViewController:trackVC animated:YES];
}

- (void) setupBarButton {
    if (!_canDelete) {
        self.navigationItem.hidesBackButton = YES;
        
        UIBarButtonItem* saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveRoutetoCoreData)];
        [self.navigationItem setRightBarButtonItem:saveBtn];
        
        UIBarButtonItem* discardBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(discardRoute)];
        [self.navigationItem setLeftBarButtonItem:discardBtn];
        
        [self.navigationItem setTitle:@"New Route"];
    }
    else {
        [self.navigationItem setTitle:[NSDateFormatter localizedStringFromDate:_startTime dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle]];
        UIBarButtonItem* deleteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteRoute)];
        [self.navigationItem setRightBarButtonItem:deleteBtn];
    }
}

- (void) maximizeMapView {
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _mapView.frame = self.view.frame;
                         _btnClose.hidden = NO;
                     }completion:^(BOOL finished) {
                         _tableView.hidden = YES;
                     }];
}

- (IBAction)minimizeMapView:(id)sender {
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _mapView.frame = CGRectMake(0, 66, 320, 210);
                         _btnClose.hidden = YES;
                         _tableView.hidden = NO;
                     }completion:nil];
}
@end
