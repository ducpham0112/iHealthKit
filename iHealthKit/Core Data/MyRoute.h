//
//  MyRoute.h
//  iHealthKit
//
//  Created by admin on 8/10/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyUser;

@interface MyRoute : NSManagedObject

@property (nonatomic, retain) NSNumber * avgSpeed;
@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * maxSpeed;
@property (nonatomic, retain) NSNumber * mood;
@property (nonatomic, retain) NSData * routePoints;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) MyUser *user;

@end
