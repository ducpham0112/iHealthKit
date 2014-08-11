//
//  Settings_SegmentCell.h
//  iHealthKit
//
//  Created by admin on 8/10/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings_SegmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end
