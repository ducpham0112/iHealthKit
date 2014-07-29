//
//  MyFetchedResultsController.m
//  iHealthKit
//
//  Created by admin on 7/27/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "MyFetchedResultsController.h"


@implementation MyFetchedResultsController 

- (id) initNew {
    MyFetchedResultsController* myData = [[MyFetchedResultsController alloc] init];
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    myData.fetchedResultsController = delegate.fetchedResultsController;
    myData.managedObjectContext = delegate.managedObjectContext;
    
    return myData;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
   // _fetchedResultsController = nil;
}

@end
