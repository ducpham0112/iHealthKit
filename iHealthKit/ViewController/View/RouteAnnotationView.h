//
//  RouteAnnotationView.h
//  iHealthKit
//
//  Created by admin on 8/7/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {
    AnnotationType_Start,
    AnnotationType_Stop
} AnnotationType;

@interface RouteAnnotationView : NSObject <MKAnnotation>

@property (nonatomic) AnnotationType type;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate type:(AnnotationType) type;

@end
