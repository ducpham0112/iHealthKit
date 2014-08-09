//
//  LeftMenuHeaderCell.h
//  iHealthKit
//
//  Created by admin on 8/9/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbAge;
@property (weak, nonatomic) IBOutlet UILabel *lbActivity;

@end
