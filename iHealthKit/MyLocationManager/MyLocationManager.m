//
//  MyLocationManager.m
//  Distance Tracking
//
//  Created by admin on 7/5/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

static const NSUInteger kDistanceFilter = 5;
static const NSUInteger kHeadingFilter = 30;
static const NSUInteger kDistanceAndSpeedCalculationInterval = 3;
static const NSUInteger kMinimumLocationUpdateInterval = 10;
static const NSUInteger kNumLocationHistoriesToKeep = 5;
static const NSUInteger kValidLocationHistoryDeltaInterval = 3;
static const NSUInteger kNumSpeedHistoriesToAverage = 5;
static const NSUInteger kMinLocationsNeededToUpdateDistanceAndSpeed = 5;
static const CGFloat kRequiredHorizontalAccuracy = 20.0;
static const CGFloat kMediumHorizontalAccuracy = 40.0;
static const CGFloat kMaximumHorizontalAccuracy = 70.0;
static const NSUInteger kGPSRefinementInterval = 15;

#import "MyLocationManager.h"

@interface MyLocationManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *locationPingTimer;
@property (nonatomic) GPSSignalStrength signalStrength;
@property (nonatomic, strong) CLLocation *lastRecordedLocation;
@property (nonatomic) CLLocationDistance totalDistance;
@property (nonatomic, strong) NSMutableArray *locationHistory;
@property (nonatomic, strong) NSDate *startTimestamp;
@property (nonatomic) double currentSpeed;
@property (nonatomic, strong) NSMutableArray *speedHistory;
@property (nonatomic) NSUInteger lastDistanceAndSpeedCalculation;
@property (nonatomic) BOOL forceDistanceAndSpeedCalculation;
@property (nonatomic) NSTimeInterval pauseDelta;
@property (nonatomic) NSTimeInterval pauseDeltaStart;
@property (nonatomic) BOOL checkingSignalStrength;
@property (nonatomic) BOOL allowMaximumAcceptableAccuracy;
@property (nonatomic) BOOL needUpdateSignalStrength;

- (void)checkSustainedSignalStrength;
- (void)requestNewLocation;

@end

@implementation MyLocationManager

+ (MyLocationManager*)shareLocationManager {
    static dispatch_once_t pred;
    static MyLocationManager *locationManagerSingleton = nil;
    
    dispatch_once(&pred, ^{
        locationManagerSingleton = [[self alloc] init];
    });
    return locationManagerSingleton;
}

- (id)init {
    if ((self = [super init])) {
        if ([CLLocationManager locationServicesEnabled]) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kDistanceFilter;
            _locationManager.headingFilter = kHeadingFilter;
        }
        
        _locationHistory = [NSMutableArray arrayWithCapacity:kNumLocationHistoriesToKeep];
        _speedHistory = [NSMutableArray arrayWithCapacity:kNumSpeedHistoriesToAverage];
        [self resetLocationUpdates];
    }
    
    return self;
}

- (void) forceUpdateSignalStrength {
    _needUpdateSignalStrength = YES;
}

- (void)setSignalStrength:(GPSSignalStrength)signalStrength {
    
    if (_signalStrength != signalStrength) {
        _needUpdateSignalStrength = YES;
    }
    
    _signalStrength = signalStrength;
    
    if (_signalStrength == strong) {
        _allowMaximumAcceptableAccuracy = NO;
    } else if (_signalStrength == medium){
        _allowMaximumAcceptableAccuracy = YES;
    } else {
        [self checkSustainedSignalStrength];
    }
    
    if (_needUpdateSignalStrength) {
        if ([_delegate respondsToSelector:@selector(locationManager:signalStrengthChanged:)]) {
            [_delegate locationManager:self signalStrengthChanged:_signalStrength];
            _needUpdateSignalStrength = NO;
        }
    }
}


- (NSTimeInterval)totalSeconds {
    return ([_startTimestamp timeIntervalSinceNow] * -1) - _pauseDelta;
}

- (void)checkSustainedSignalStrength {
    
    if (_signalStrength == invalid) {
        if ([_delegate respondsToSelector:@selector(locationManagerSignalInvalid:)]) {
            [_delegate locationManagerSignalInvalid:self];
        }
    }

    if (!_isStarted) {
        return;
    }
    
    if (!_checkingSignalStrength) {
        _checkingSignalStrength = YES;
        double delayInSeconds = kGPSRefinementInterval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _checkingSignalStrength = NO;
            if (_signalStrength == weak || _signalStrength == medium) {
                _allowMaximumAcceptableAccuracy = YES;
                if ([_delegate respondsToSelector:@selector(locationManagerSignalConsistentlyWeak:)]) {
                    [_delegate locationManagerSignalConsistentlyWeak:self];
                    }
                }
            }
        );
    }
}

- (void)requestNewLocation {
    [_locationManager stopUpdatingLocation];
    [_locationManager startUpdatingLocation];
}

- (BOOL)prepLocationUpdates {
    if ([CLLocationManager locationServicesEnabled]) {
        [_locationHistory removeAllObjects];
        [_speedHistory removeAllObjects];
        _lastDistanceAndSpeedCalculation = 0;
        _currentSpeed = -1;
        _allowMaximumAcceptableAccuracy = NO;
        _needUpdateSignalStrength = YES;
        
        _forceDistanceAndSpeedCalculation = YES;
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        
        
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        
        if (_pauseDeltaStart > 0) {
            _pauseDelta += ([NSDate timeIntervalSinceReferenceDate] - _pauseDeltaStart);
            _pauseDeltaStart = 0;
        }
        _startTimestamp = nil;
        _lastRecordedLocation = nil;
        
        return YES;
    } else {
        [self setSignalStrength:invalid];
        return NO;
    }
}

- (BOOL)startLocationUpdates {
    if (![CLLocationManager locationServicesEnabled]) {
        [self setSignalStrength:invalid];
        return NO;
    }
    _isStarted = YES;
    return YES;
}

- (void)stopLocationUpdates {
    [_locationPingTimer invalidate];
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
    _pauseDeltaStart = [NSDate timeIntervalSinceReferenceDate];
    _lastRecordedLocation = nil;
    _isStarted = NO;
}

- (void)resetLocationUpdates {
    _totalDistance = 0;
    _startTimestamp = nil;
    _forceDistanceAndSpeedCalculation = NO;
    _pauseDelta = 0;
    _pauseDeltaStart = 0;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* curLocation = [locations lastObject];
    
    [_locationPingTimer invalidate];
    
    if (curLocation.horizontalAccuracy <= kRequiredHorizontalAccuracy) {
        [self setSignalStrength:strong];
    } else if (curLocation.horizontalAccuracy <= kMediumHorizontalAccuracy){
        [self setSignalStrength:medium];
    } else {
        [self setSignalStrength:weak];
    }
    
    if ([_delegate respondsToSelector:@selector(locationManager:locationUpdate:)]) {
        [_delegate locationManager:self locationUpdate:[locations firstObject]];
    }
    
    if (!_isStarted) {
        
        return;
    }
    
    double horizontalAccuracy;
    if (_allowMaximumAcceptableAccuracy) {
        horizontalAccuracy = kMaximumHorizontalAccuracy;
    } else {
        horizontalAccuracy = kRequiredHorizontalAccuracy;
    }
    
    if (_lastRecordedLocation == nil) {
        //CLLocation* curLocation = [locations lastObject];
        if (curLocation.horizontalAccuracy > 0 && curLocation.horizontalAccuracy < horizontalAccuracy) {
            _lastRecordedLocation = [locations lastObject];
            _startTimestamp = _lastRecordedLocation.timestamp;
            if ([_delegate respondsToSelector:@selector(locationManager:startTimeStamp:)]) {
                [_delegate locationManager:self startTimeStamp:_startTimestamp];
            }
        }
        return;
    }
    
    if (curLocation.horizontalAccuracy >= 0 && curLocation.horizontalAccuracy <= horizontalAccuracy) {
        
        [_locationHistory addObject:curLocation];
        if ([_locationHistory count] > kNumLocationHistoriesToKeep) {
            [_locationHistory removeObjectAtIndex:0];
        }
        
        BOOL canUpdateDistanceAndSpeed = NO;
        if ([_locationHistory count] >= kMinLocationsNeededToUpdateDistanceAndSpeed) {
            canUpdateDistanceAndSpeed = YES;
        }
        
        if (_forceDistanceAndSpeedCalculation || [NSDate timeIntervalSinceReferenceDate] - _lastDistanceAndSpeedCalculation > kDistanceAndSpeedCalculationInterval) {
            _forceDistanceAndSpeedCalculation = NO;
            _lastDistanceAndSpeedCalculation = [NSDate timeIntervalSinceReferenceDate];
            
            //CLLocation* lastLocation = _lastRecordedLocation;
            
            CLLocation *bestLocation = nil;
            CGFloat bestAccuracy = kRequiredHorizontalAccuracy;
            for (CLLocation *location in _locationHistory) {
                if ([NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate] <= kValidLocationHistoryDeltaInterval) {
                    if (location.horizontalAccuracy <= bestAccuracy && location != _lastRecordedLocation) {
                        bestAccuracy = location.horizontalAccuracy;
                        bestLocation = location;
                    }
                }
            }
            if (bestLocation == nil)
                bestLocation = curLocation;
            
            CLLocationDistance distance = [bestLocation distanceFromLocation:_lastRecordedLocation];
            if (canUpdateDistanceAndSpeed) _totalDistance += distance;
            
            NSTimeInterval timeSinceLastLocation = [bestLocation.timestamp timeIntervalSinceDate:_lastRecordedLocation.timestamp];
            if (timeSinceLastLocation > 0) {
                CGFloat speed = distance / timeSinceLastLocation;
                if (speed <= 0 && [_speedHistory count] == 0) {
                    // don't add a speed of 0 as the first item, since it just means we're not moving yet
                } else {
                    [_speedHistory addObject:[NSNumber numberWithDouble:speed]];
                }
                if ([_speedHistory count] > kNumSpeedHistoriesToAverage) {
                    [_speedHistory removeObjectAtIndex:0];
                }
                if ([_speedHistory count] > 1) {
                    double totalSpeed = 0;
                    for (NSNumber *speedNumber in _speedHistory) {
                        totalSpeed += [speedNumber doubleValue];
                    }
                    if (canUpdateDistanceAndSpeed) {
                        _currentSpeed = totalSpeed / (double)[_speedHistory count];
                    }
                }
            }
            
            if ([_delegate respondsToSelector:@selector(locationManager:routePoint:calculatedSpeed:)]) {
                [_delegate locationManager:self routePoint:_lastRecordedLocation calculatedSpeed:_currentSpeed];
            }
            
            _lastRecordedLocation = bestLocation;
        }
    }
    
    // this will be invalidated above if a new location is received before it fires
    _locationPingTimer = [NSTimer timerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(requestNewLocation) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_locationPingTimer forMode:NSRunLoopCommonModes];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //force to calculate distance
    _forceDistanceAndSpeedCalculation = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        if ([_delegate respondsToSelector:@selector(locationManager:error:)]) {
            [_delegate locationManager:self error:error];
        }
        [self stopLocationUpdates];
    }
}

@end









