//
//  CommonFunctions.m
//  iHealthKit
//
//  Created by admin on 7/19/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "CommonFunctions.h"
#import "LeftMenuViewController.h"
#import "TrackingViewController.h"
#import "MyNavigationViewController.h"
#import "MyVisualStateManager.h"
#import "SettingsViewController.h"

#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)

@implementation CommonFunctions

+ (void) setupDrawer {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
    UIViewController * leftSideDrawerViewController = [[LeftMenuViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UIViewController * centerViewController = [[TrackingViewController alloc] initWithNibName:@"TrackingViewController" bundle:nil];
    //UIViewController * rightSideDrawerViewController = [[MMExampleRightSideDrawerViewController alloc] init];
    
    MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:centerViewController];
    [navigationController setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
    
    MyNavigationViewController * leftSideNavController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:leftSideDrawerViewController];
    [leftSideNavController setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
    
    SettingsViewController* settingVC = [[SettingsViewController alloc] initRightDrawer];
    MyNavigationViewController * rightNavigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:settingVC];

    delegate.drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:leftSideDrawerViewController rightDrawerViewController:rightNavigationController];
    [delegate.drawerController setMaximumLeftDrawerWidth:220.0];
     [delegate.drawerController setMaximumRightDrawerWidth:240.0];
    [delegate.drawerController setShowsShadow:NO];
    
    [delegate.drawerController setRestorationIdentifier:@"MMDrawer"];
    
    [delegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [delegate.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [delegate.drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block;
        block = [[MyVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
        if(block){
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    
    [delegate.window setRootViewController:delegate.drawerController];
}

+ (void)showStatusBarAlert:(NSString *)message duration:(float)duration backgroundColor:(UIColor *)bgColor {
    CWStatusBarNotification* statusNotification = [[CWStatusBarNotification alloc] init];
    [statusNotification setNotificationLabelBackgroundColor:bgColor];
    [statusNotification setNotificationLabelTextColor:[UIColor whiteColor]];
    [statusNotification displayNotificationWithMessage:message forDuration:duration];
}

+ (NSString*)stringSecondFromInterval: (NSTimeInterval) timeInterval
{
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = (int)timeInterval;
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", ti / SECONDS_PER_HOUR, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    }

+ (NSString*) stringMinuteFromInterval: (NSTimeInterval) time {

    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = (int)time;
    
    return [NSString stringWithFormat:@"%.2d:%.2d", (ti / SECONDS_PER_HOUR),  (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR];

}

+ (NSString*) paceStr: (NSTimeInterval) time {
#define SECONDS_PER_MINUTE (60)
    int ti = (int) time;
    return [NSString stringWithFormat:@"%.2d:%.2d", (ti/SECONDS_PER_MINUTE), (ti % SECONDS_PER_MINUTE)];
}

+ (int) timePart: (NSTimeInterval) time withPart:(DatePartType) part {


    int ti = (int) time;
    switch (part) {
        case DatePartType_hour:
            return ti / SECONDS_PER_HOUR;
            break;
        case DatePartType_minute:
            return  (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR;
            break;
        case DatePartType_second:
            return ti % SECONDS_PER_MINUTE;
            break;
        default:
            return 0;
            break;
    }}

+ (NSTimeInterval)durationFrom:(NSDate *)startTime To:(NSDate *)endTime {
    NSTimeInterval totalTime = ([endTime timeIntervalSinceDate:startTime]);
    return totalTime;
}

+ (UIColor*) leftMenuBackgroundColor {
    return [UIColor colorWithRed:28.0f/255 green:85.0f/255 blue:130.0f/255 alpha:1.0f];
}

+ (UIColor*) navigationBarColor {
    return [UIColor colorWithRed:35.0f/255 green:126.0f/255 blue:196.0f/255 alpha:1.0f];
}

+ (UIColor *)grayColor {
    return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
}

+ (UIColor *)lightGrayColor {
    return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.15f];
}

+ (UIColor *)redColor {
    return [UIColor colorWithRed:212.0/255 green:61.0/255 blue:79.0/255 alpha:1.0];
}

+ (UIColor*) yellowColor {
    return [UIColor colorWithRed:250.0/255 green:157.0/255 blue:37.0/255 alpha:1.0];
}

+ (UIColor *)greenColor {
    return [UIColor colorWithRed:155.0/255 green:208.0/255 blue:65.0/255 alpha:1.0];
}

+ (NSDate*) dateFromString:(NSString *)dateString withFormat: (NSString*) format{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    
    if (format == nil) {
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
    }
    else {
        [dateFormat setDateFormat:format];
    }
    
    return [dateFormat dateFromString:dateString];
}


+ (int)datePart:(NSDate *)date withPart:(DatePartType) part
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:date];
    
    switch (part) {
        case DatePartType_year:
            return [components year];
            break;
            
        case DatePartType_month:
            return [components month];
            break;
            
        case DatePartType_day:
            return [components day];
            break;
        case DatePartType_hour:
            return [components hour];
            break;
        case DatePartType_minute:
            return [components minute];
            break;
        case DatePartType_second:
            return [components second];
            break;
        default:
            return -1;
            break;
    }
}

+ (float) convertMPStoMiPH: (float) speedInMetersPerSec {
    return (speedInMetersPerSec * 2.2369362920544);
}
+ (float) convertMiPHtoMPS: (float) speedInMilePerHour {
    return (speedInMilePerHour / 2.2369362920544);
}

+ (float) convertHeightToCm:(float)height {
    return height*30.48;
}
+ (float) convertHeightToFt: (float) height {
    return height/30.48;
}

+ (float) convertWeightToKg: (float) weight {
    return weight*0.453592;
}
+ (float) convertWeightToLb: (float) weight {
    return weight/0.453592;
}

+ (float) convertHeight:(float)heightInCm {
    int distanceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    switch (distanceType) {
        case 0:
            return heightInCm;
            break;
        case 1:
            return [self convertHeightToFt:heightInCm];
            break;
        default:
            break;
    }
    return heightInCm;
}

+ (float)convertWeight:(float)weightInKg {
    int weightUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"WeightUnit"];
    switch (weightUnit) {
        case 1:
            return [self convertWeightToLb:weightInKg];
            break;
        default:
            break;
    }
    return weightInKg;
}


+ (float) convertSpeed: (float) speedInMeterPerSec {
    int velocityUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"VelocityUnit"];
    int distanceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    
    float factor = 1;
    switch (distanceType) {
        case 0:{
            switch (velocityUnit) {
                case 0: {
                    //km per hour
                    factor = 3.6;
                    break;
                }
                case 1: {
                    // meter per second
                    factor = 1;
                    break;
                }
               
            }
            break;
        }
        case 1: {
            switch (velocityUnit) {
                case 0: {
                    // mph
                    factor = 2.23694;
                    break;
                }
                case 1: {
                    // fps
                    factor = 3.28084;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return speedInMeterPerSec * factor;
}

+ (float) convertDistance: (float) distanceInMeter {
    int distanceUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceUnit"];
    int distanceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    
    float factor = 1;
    switch (distanceType) {
        case 0:
            switch (distanceUnit) {
                case 0: {
                    factor = 0.001;
                    break;
                }
                case 1: {
                    break;
                }
                default:
                    break;
            }
            break;
        case 1: {
            switch (distanceUnit) {
                case 0:
                    factor = 0.000621371;
                    break;
                 case 1:
                    factor = 3.28084;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return distanceInMeter * factor;
}

+ (NSString*) paceStrFromSpeed:(float)speedInMeterPerSec{
    int distanceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    
    NSString* paceStr;
    float pace;
    switch (distanceType) {
        case 0:
            //metric min/km
            pace = 1 / [self convertDistanceToKm:speedInMeterPerSec];
            paceStr = [self paceStr:pace];
            break;
        case 1:
            //us system min/mile
            pace = 1 / [self convertDistanceToMile:speedInMeterPerSec];
            paceStr = [self paceStr:pace];
        default:
            break;
    }
    return paceStr;
}

+ (void) setTrackingStatus:(BOOL)status {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    delegate.isTracking = status;
}

+ (BOOL) trackingStatus {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    return delegate.isTracking;
}

+ (float) convertDistanceToKm:(float)distanceInMeter {
    return distanceInMeter/1000;
}

+ (float)convertDistanceToMile:(float)distanceInMeter {
    return distanceInMeter/1609.34;
}

+ (NSString*) distanceUnitStr {
    NSString* distanceUnit = @"";
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"]) {
        case 0: {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceUnit"]) {
                case 0:
                    distanceUnit = @"km";
                    break;
                case 1:
                    distanceUnit = @"m";
                    break;
                default:
                    break;
            }
            break;
        }
        case 1: {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceUnit"]) {
                case 0:
                    distanceUnit = @"mi";
                    break;
                case 1:
                    distanceUnit = @"ft";
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return distanceUnit;
}

+ (NSString*) paceUnitStr {
    NSString* paceStr = @"";
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"])  {
        case 0:
            paceStr =  @"sec/km";
            break;
        case 1:
            paceStr = @"sec/mile";
        default:
            break;
    }
    return paceStr;
}

+ (NSString*) speedUnitStr {
    NSString* velocityUnit = @"";
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"]) {
        case 0: {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"VelocityUnit"]) {
                case 0:
                    velocityUnit = @"km/h";
                    break;
                case 1:
                    velocityUnit = @"m/s";
                    break;
                default:
                    break;
            }
            break;
        }
        case 1: {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceUnit"]) {
                case 0:
                    velocityUnit = @"mph";
                    break;
                case 1:
                    velocityUnit = @"fps";
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return velocityUnit;
}


@end
