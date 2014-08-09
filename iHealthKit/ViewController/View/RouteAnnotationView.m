//
//  RouteAnnotationView.m
//  iHealthKit
//
//  Created by admin on 8/7/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "RouteAnnotationView.h"
#import <MapKit/MapKit.h>

@implementation RouteAnnotationView


-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate type:(AnnotationType) type {
    RouteAnnotationView* routeAnnotation = [[RouteAnnotationView alloc] init];
    routeAnnotation.coordinate = coordinate;
    routeAnnotation.type = type;
    return routeAnnotation;
}

@end
