//
//  ListRouteTableViewCell.h
//  iHealthKit
//
//  Created by admin on 7/21/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lbDistanceDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbDistanceValue;
@property (weak, nonatomic) IBOutlet UILabel *lbDurationValue;
@property (weak, nonatomic) IBOutlet UILabel *lbDurationDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbAvgSpeedValue;
@property (weak, nonatomic) IBOutlet UILabel *lbAvgSpeedDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgDayNight;

@end
