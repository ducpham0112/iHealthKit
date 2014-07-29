//
//  CoreDataFuntions.m
//  iHealthKit
//
//  Created by admin on 7/21/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "CoreDataFuntions.h"

@implementation CoreDataFuntions

+ (MyUser*) getCurUser {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    for (MyUser* user in delegate.fetchedResultsController.fetchedObjects) {
        if ([user.isCurrentUser boolValue]) {
            return user;
        }
    }
    return nil;
}

+ (BOOL) switchUser: (MyUser*) newUser{
    if (newUser == [self getCurUser]) {
        return YES;
    }
    
    while (YES){
        MyUser* curUser = [CoreDataFuntions getCurUser];
        if (curUser != nil) {
            curUser.isCurrentUser = [NSNumber numberWithBool:NO];
        }
        else {
            break;
        }
    }
    
    newUser.isCurrentUser = [NSNumber numberWithBool:YES];
    return [self saveContent];
}

+ (MyUser*) getUserAtIndex: (int) index {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    if (index < [delegate.fetchedResultsController.fetchedObjects count]) {
        return [delegate.fetchedResultsController.fetchedObjects objectAtIndex:index];
    }
    return nil;
}

+ (NSArray*) getListUser {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    return delegate.fetchedResultsController.fetchedObjects;
}

+ (BOOL) saveNewUser:(NSString *)firstName lastName:(NSString *)lastName height:(NSNumber*)height weight:(NSNumber*)weight birthDate:(NSDate *)birthDate email:(NSString *)email gender:(NSNumber*)isMale{
    while (YES){
        MyUser* curUser = [CoreDataFuntions getCurUser];
        if (curUser != nil) {
            curUser.isCurrentUser = [NSNumber numberWithBool:NO];
        }
        else {
            break;
        }
    }
    
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    MyUser* newUser = (MyUser*)[NSEntityDescription insertNewObjectForEntityForName:@"MyUser" inManagedObjectContext:delegate.managedObjectContext];
    newUser.firstName = firstName;
    newUser.lastName = lastName;
    newUser.weight = weight;
    newUser.height = weight;
    newUser.birthday = birthDate;
    newUser.email = email;
    newUser.isMale = isMale;
    newUser.routeHistory = nil;
    newUser.isCurrentUser = [NSNumber numberWithBool:YES];
    
    return [self saveContent];
}

+ (BOOL) deleteUser: (MyUser*) deleteUser {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    if ([deleteUser.isCurrentUser boolValue]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Cannot delete current user" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        NSLog(@"Cannot delete current user");
        return NO;
    }
    else {
        for (MyRoute* route in deleteUser.routeHistory) {
            [delegate.managedObjectContext deleteObject:route];
        }
        [delegate.managedObjectContext deleteObject:deleteUser];
        return [self saveContent];
    }
}

+ (BOOL) saveNewRoute:(NSDate *)startTime endTime:(NSDate *)endTime calories:(float)calories maxSpeed:(float)maxSpeed avgSpeed:(float)avgSpeed distance:(float)distance locations:(NSData *)locations mood:(int)mood{
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    MyRoute* newRoute = (MyRoute*) [NSEntityDescription insertNewObjectForEntityForName:@"MyRoute" inManagedObjectContext:delegate.managedObjectContext];
    newRoute.calories = [NSNumber numberWithFloat:calories];
    newRoute.startTime = startTime;
    newRoute.endTime = endTime;
    newRoute.maxSpeed = [NSNumber numberWithFloat:maxSpeed];
    newRoute.avgSpeed = [NSNumber numberWithFloat:avgSpeed];
    newRoute.distance = [NSNumber numberWithFloat:distance];
    newRoute.routePoints = locations;
    newRoute.mood = [NSNumber numberWithInt:mood];
    
    MyUser* curUser = [self getCurUser];
    newRoute.user = curUser;
    [curUser addRouteHistoryObject:newRoute];
    
    return [self saveContent];
}

+ (BOOL) deleteRoute: (MyRoute*) deleteRoute {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    MyUser* user = deleteRoute.user;
    [user removeRouteHistoryObject:deleteRoute];
    [delegate.managedObjectContext deleteObject:deleteRoute];
    
    return [self saveContent];
}

+ (NSString *)getFullnameUser:(MyUser *)user {
    return [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
}

+ (BOOL) saveContent {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    NSError* error;
    [delegate.managedObjectContext save:&error];
    if (error == nil) {
        return YES;
    }
    else {
        NSLog(@"Fail to save content! Error: %@", [error userInfo]);
        return NO;
    }
}

@end
