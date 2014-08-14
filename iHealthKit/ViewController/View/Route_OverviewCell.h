//
//  RouteHeaderTableViewCell.h
//  iHealthKit
//
//  Created by admin on 7/26/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Route_OverviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbDistance;
@property (weak, nonatomic) IBOutlet UILabel *lbDistanceUnit;
@property (weak, nonatomic) IBOutlet UILabel *lbDuration;
@property (weak, nonatomic) IBOutlet UILabel *lbCalories;

@end
