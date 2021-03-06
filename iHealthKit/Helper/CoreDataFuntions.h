//
//  CoreDataFuntions.h
//  iHealthKit
//
//  Created by admin on 7/21/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyUser.h"

@interface CoreDataFuntions : NSObject
+ (MyUser*) curUser;
+ (NSArray*) listUser;

+ (BOOL) switchUser: (MyUser*) newUser;
+ (BOOL) saveNewUser:(NSString *)firstName lastName:(NSString *)lastName height:(NSNumber*)height weight:(NSNumber*)weight birthDate:(NSDate *)birthDate email:(NSString *)email gender:(NSNumber*)isMale avatar:(NSData*) avatar;
+ (BOOL) deleteUser: (MyUser*) deleteUser;

+ (BOOL) saveNewRoute: (NSDate*) startTime endTime:(NSDate*) endTime calories:(float)calories maxSpeed:(float) maxSpeed avgSpeed:(float) avgSpeed distance:(float) distance locations:(NSData*) locations mood:(int) mood;
+ (BOOL) deleteRoute: (MyRoute*) deleteRoute;
+ (NSString*) fullName: (MyUser*) user;

+ (BOOL) saveContent;

@end
