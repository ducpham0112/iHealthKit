//
//  MyUser.h
//  iHealthKit
//
//  Created by admin on 7/25/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyRoute;

@interface MyUser : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * isCurrentUser;
@property (nonatomic, retain) NSNumber * isMale;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet *routeHistory;
@end

@interface MyUser (CoreDataGeneratedAccessors)

- (void)addRouteHistoryObject:(MyRoute *)value;
- (void)removeRouteHistoryObject:(MyRoute *)value;
- (void)addRouteHistory:(NSSet *)values;
- (void)removeRouteHistory:(NSSet *)values;

@end
