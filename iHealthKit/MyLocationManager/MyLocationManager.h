//
//  MyLocationManager.h
//  Distance Tracking
//
//  Created by admin on 7/5/14.
//  Copyright (c) 2014 iOS Fresher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class MyLocationManager;

typedef enum {
    invalid = 0,
    weak,
    strong
} GPSSignalStrength;

@protocol MyLocationManagerDelegate <NSObject>

@optional
- (void)locationManager:(MyLocationManager *)locationManager signalStrengthChanged:(GPSSignalStrength)signalStrength;

//- (void)locationManager:(MyLocationManager *)locationManager distanceUpdated:(CLLocationDistance)distance;
- (void)locationManager:(MyLocationManager *)locationManager routePoint:(CLLocation *)routePoint calculatedSpeed:(double)calculatedSpeed;

- (void)locationManager:(MyLocationManager *)locationManager error:(NSError *)error;

- (void)locationManagerSignalConsistentlyWeak:(MyLocationManager *)locationManager;
- (void)locationManagerSignalInvalid:(MyLocationManager *)locationManager;

- (void)locationManager:(MyLocationManager *)locationManager startTimeStamp:(NSDate*)startTimeStamp;

- (void)locationManager:(MyLocationManager *)locationManager locationUpdate:(CLLocation*)location;



@end

@interface MyLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<MyLocationManagerDelegate> delegate;
@property (nonatomic, readonly) GPSSignalStrength signalStrength;
@property (nonatomic, readonly) CLLocationDistance totalDistance;
@property (nonatomic, readonly) NSTimeInterval totalSeconds;

@property (nonatomic) BOOL isStarted;

+ (MyLocationManager*) shareLocationManager;

-(BOOL) prepLocationUpdates;
-(BOOL) startLocationUpdates;
-(void) stopLocationUpdates;
-(void) resetLocationUpdates;

@end
