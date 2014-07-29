//
//  RouteViewController.h
//  iHealthKit
//
//  Created by admin on 7/19/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RouteViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lbDuration;
@property (weak, nonatomic) IBOutlet UILabel *lbDistance;
@property (weak, nonatomic) IBOutlet UILabel *lbCalories;
@property (weak, nonatomic) IBOutlet UILabel *lbAvgSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lbMaxSpeed;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

- (id) initwithRoute: (MyRoute*) route;
-(id) initNewRoute: (NSDate*) startTime endtime:(NSDate*)endTime distance:(float)distance maxSpeed:(float)maxSpeed averageSpeed:(float) avgSpeed trainingType:(int)trainingType calories:(float) calories locationData:(NSMutableArray*) locationData routePoints:(NSMutableArray*) routePoints;
@end
