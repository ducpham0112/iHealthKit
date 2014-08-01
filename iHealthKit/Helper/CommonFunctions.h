//
//  CommonFunctions.h
//  iHealthKit
//
//  Created by admin on 7/19/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyUser.h"
#import "CWStatusBarNotification.h"

@interface CommonFunctions : NSObject
+ (void) setupDrawer ;

+ (void) showStatusBarAlert: (NSString*) message duration: (float) duration backgroundColor: (UIColor*) bgColor;

+ (NSString*)stringSecondFromInterval: (NSTimeInterval) timeInterval;
+ (NSString*) stringMinuteFromInterval: (double) time ;

+ (NSTimeInterval) getDuration: (NSDate*) startTime endTime: (NSDate*) endTime;

+ (UIColor*) leftMenuBackgroundColor;

+ (UIColor*) navigationBarColor;

+ (UIColor*) grayColor;
+ (UIColor*) lightGrayColor;

+ (NSDate*) dateFromString:(NSString *)dateString withFormat: (NSString*) format;

+ (void) setTrackingStatus:(BOOL)status;
+ (BOOL) getTrackingStatus;

+ (NSString*) getPaceUnitString ;
+ (NSString*) getDistanceUnitString;
+ (NSString*) getVelocityUnitString;

+ (float) convertMPStoMiPH: (float) speedInMetersPerSec;
+ (float) convertMiPHtoMPS: (float) speedInMilePerHour;

+ (float) convertWeightToLb: (float) weight;
+ (float) convertWeightToKg: (float) weight;

+ (float) convertHeightToCm: (float) height;
+ (float) convertHeightToFt: (float) height;

+ (float) convertWeight: (float) weightInKg;
+ (float) convertDistance: (float) distanceInMeter;
+ (float) convertSpeed: (float) speedInMeterPerSec;
+ (float) convertHeight: (float) heightInCm;
+ (NSString*) convertPace: (float) speedInMeterPerSec;

+ (float) convertDistanceToKm: (float) distanceInMeter;
+ (float) convertDistanceToMile: (float) distanceInMeter;

+ (float) convertTimeToMinute: (NSTimeInterval) timeInSecond;
+ (float) convertTimeToHour: (NSTimeInterval) timeInSecond;
@end
