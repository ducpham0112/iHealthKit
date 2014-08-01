//
//  CommonFunctions.m
//  iHealthKit
//
//  Created by admin on 7/19/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "CommonFunctions.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "LeftMenuTableViewController.h"
#import "TrackingViewController.h"
#import "MyNavigationViewController.h"
#import "MyVisualStateManager.h"


@implementation CommonFunctions

+ (void) setupDrawer {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
    UIViewController * leftSideDrawerViewController = [[LeftMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UIViewController * centerViewController = [[TrackingViewController alloc] initWithNibName:@"TrackingViewController" bundle:nil];
    //UIViewController * rightSideDrawerViewController = [[MMExampleRightSideDrawerViewController alloc] init];
    
    MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:centerViewController];
    [navigationController setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
    
    MyNavigationViewController * leftSideNavController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions leftMenuBackgroundColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:leftSideDrawerViewController];
    [leftSideNavController setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
    
    delegate.drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:leftSideNavController rightDrawerViewController:nil];
    [delegate.drawerController setMaximumLeftDrawerWidth:220.0];
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
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = (int)timeInterval;
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
#undef HOURS_PER_DAY
}

+ (NSString*) stringMinuteFromInterval: (NSTimeInterval) time {
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = (int)time;
    
    return [NSString stringWithFormat:@"%.2d:%.2d", (ti / MINUTES_PER_HOUR), (ti  % MINUTES_PER_HOUR)];
    
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
#undef HOURS_PER_DAY
}

+ (NSTimeInterval)getDuration:(NSDate *)startTime endTime:(NSDate *)endTime {
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
    return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f];
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
        }
        default:
            break;
    }
    return distanceInMeter * factor;
}

+ (NSString*) convertPace:(float)speedInMeterPerSec{
    int distanceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    NSString* paceStr;
    float pace;
    switch (distanceType) {
        case 0:
            //metric min/km
            pace = speedInMeterPerSec * 1000 / 60;
            paceStr = [self stringMinuteFromInterval:pace];
            break;
        case 1:
            //us system min/mile
            pace = speedInMeterPerSec / 0.000621371 / 60;
            paceStr = [self stringMinuteFromInterval:pace];
        default:
            break;
    }
    return paceStr;
}

+ (void) setTrackingStatus:(BOOL)status {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    delegate.isTracking = status;
}

+ (BOOL) getTrackingStatus {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    return delegate.isTracking;
}

+ (float) convertDistanceToKm:(float)distanceInMeter {
    return distanceInMeter/1000;
}

+ (float)convertDistanceToMile:(float)distanceInMeter {
    return distanceInMeter/1609.34;
}

+ (float) convertTimeToMinute: (NSTimeInterval) timeInSecond {
    return timeInSecond / 60;
}

+ (float) convertTimeToHour: (NSTimeInterval) timeInSecond {
    return timeInSecond / 3600;
}


+ (NSString*) getDistanceUnitString {
    NSString* distanceUnit = @"";
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"]) {
        case 0: {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DitanceUnit"]) {
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

+ (NSString*) getPaceUnitString {
    NSString* paceStr = @"";
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"])  {
        case 0:
            paceStr =  @"min/km";
            break;
        case 1:
            paceStr = @"min/mile";
        default:
            break;
    }
    return paceStr;
}

+ (NSString*) getVelocityUnitString {
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
