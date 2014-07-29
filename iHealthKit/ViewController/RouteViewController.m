//
//  RouteViewController.m
//  iHealthKit
//
//  Created by admin on 7/19/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "RouteViewController.h"
#import "HistoryTableViewController.h"
#import "TrackingViewController.h"
#import "View/RouteHeaderTableViewCell.h"
#import "View/RouteDetailTableViewCell.h"

typedef enum  {
    RowType_TrainingType = 0,
    RowType_StartTime,
    RowType_EndTime,
    RowType_AvgSpeed,
    RowType_MaxSpeed,
    RowType_AvgPace
} RowType;

@interface RouteViewController ()

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
    routeVC.locationDatatoStore = locationData;
    routeVC.routePoints = routePoints;

    return routeVC;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _unit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceUnit"];
    _duration = [CommonFunctions getDuration:_startTime endTime:_endTime];
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.tableView registerNib:[UINib nibWithNibName:@"RouteDetailTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"routeDetailCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RouteHeaderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"routeHeaderCell"];
    
    [_mapView setDelegate:self];
    [_mapView showsUserLocation];
    
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
            cell = [[RouteHeaderTableViewCell alloc] init];
        }
        
    }
    else {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"routeDetailCell"];
        if (cell == nil) {
            cell = [[RouteDetailTableViewCell alloc] init];
        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell: (UITableViewCell*) cell atIndexPath: (NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        RouteHeaderTableViewCell* headerCell = (RouteHeaderTableViewCell*) cell;
        headerCell.lbCalories.text = [NSString stringWithFormat:@"%.0f", _calories];
        headerCell.lbDistance.text = [NSString stringWithFormat:@"%.2f", _distance];
        
        NSString* unit;
        if (_unit == 1) {
            unit = @"mi";
        }
        else {
            unit = @"km";
        }
        headerCell.lbDistanceUnit.text = [NSString stringWithFormat:@"Distance (%@)", unit];
        headerCell.lbDistance.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertDistance:_distance]];
        headerCell.lbDuration.text = [CommonFunctions stringFromInterval:_duration];
    }
    
    else {
        RouteDetailTableViewCell* detailCell = (RouteDetailTableViewCell*) cell;
        
        switch (indexPath.row) {
            case RowType_AvgPace: {
                detailCell.lbDescription.text = @"Average Pace";
                double pace = _duration / _distance;
                detailCell.lbDetail.text = [CommonFunctions stringFromInterval:pace];
                [detailCell.imageView setImage:[UIImage imageNamed:@"LeftMenuIcon.png"]];
                break;
            }
            case RowType_AvgSpeed: {
                detailCell.lbDescription.text = @"Average Speed";
                float avgSpeed = [CommonFunctions convertSpeed:_averageSpeed];
                detailCell.lbDetail.text = [NSString stringWithFormat:@"%.2f", avgSpeed];
                break;
            }
            case RowType_EndTime: {
                detailCell.lbDescription.text = @"End Time";
                detailCell.lbDetail.text = [NSDateFormatter localizedStringFromDate:_endTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                break;
            }
            case RowType_MaxSpeed: {
                detailCell.lbDescription.text = @"Max. Speed";
                detailCell.lbDetail.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertSpeed:_maxSpeed]];
                break;
            }
            case RowType_StartTime: {
                detailCell.lbDescription.text = @"Start Time";
                detailCell.lbDetail.text = [NSDateFormatter localizedStringFromDate:_startTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                break;
            }
            case RowType_TrainingType: {
                NSString* trainingStr;
                if (_trainingType == 1) {
                    trainingStr = @"Biking";
                }
                else {
                    trainingStr = @"Running";
                }
                detailCell.lbDetail.text = trainingStr;
                detailCell.lbDescription.text = @"Traing Type";
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
        } else {
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
    
#warning alert message here
    [CommonFunctions showStatusBarAlert:@"New route has been added to your history." duration:3.0f backgroundColor: [UIColor greenColor]];
    TrackingViewController* trackVC = [[TrackingViewController alloc] init];
    [self.navigationController pushViewController:trackVC animated:YES];
}

- (void) deleteRoute {
    [CoreDataFuntions deleteRoute:_route];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HistoryChanged" object:self];
    HistoryTableViewController* historyVC = [[HistoryTableViewController alloc]  init];
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (void) discardRoute {
    [CommonFunctions showStatusBarAlert:@"Route has been discarded." duration:3.0f backgroundColor: [UIColor redColor]];
    TrackingViewController* trackVC = [[TrackingViewController alloc] init];
    [self.navigationController pushViewController:trackVC animated:YES];
}

@end
