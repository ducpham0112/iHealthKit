//
//  CommonFunctions.h
//  iHealthKit
//
//  Created by admin on 7/19/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWStatusBarNotification.h"

typedef enum {
    DatePartType_year,
    DatePartType_month,
    DatePartType_day,
    DatePartType_hour,
    DatePartType_minute,
    DatePartType_second
} DatePartType;

@interface CommonFunctions : NSObject
+ (void) setupDrawer ;

+ (void) showStatusBarAlert: (NSString*) message duration: (float) duration backgroundColor: (UIColor*) bgColor;

+ (NSString*) stringSecondFromInterval: (NSTimeInterval) timeInterval;
+ (NSString*) stringMinuteFromInterval: (double) time ;
+ (int) timePart: (NSTimeInterval) time withPart:(DatePartType) part;
+ (NSTimeInterval) durationFrom: (NSDate*) startTime To: (NSDate*) endTime;

+ (UIColor*) leftMenuBackgroundColor;
+ (UIColor*) navigationBarColor;
+ (UIColor*) grayColor;
+ (UIColor*) lightGrayColor;
+ (UIColor*) greenColor;
+ (UIColor*) redColor;
+ (UIColor*) yellowColor;

+ (NSDate*) dateFromString:(NSString *)dateString withFormat: (NSString*) format;
+ (int)datePart:(NSDate *)date withPart:(DatePartType) part;

+ (void) setTrackingStatus:(BOOL)status;
+ (BOOL) trackingStatus;

+ (NSString*) paceUnitStr ;
+ (NSString*) distanceUnitStr;
+ (NSString*) speedUnitStr;

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
+ (NSString*) paceStrFromSpeed: (float) speedInMeterPerSec;

+ (float) convertDistanceToKm: (float) distanceInMeter;
+ (float) convertDistanceToMile: (float) distanceInMeter;

@end
