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

- (id) initwithRoute: (MyRoute*) route;
-(id) initNewRoute: (NSDate*) startTime endtime:(NSDate*)endTime distance:(float)distance maxSpeed:(float)maxSpeed averageSpeed:(float) avgSpeed trainingType:(int)trainingType calories:(float) calories locationData:(NSMutableArray*) locationData routePoints:(NSMutableArray*) routePoints;
@end
