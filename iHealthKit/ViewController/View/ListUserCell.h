//
//  UserTableViewCell.h
//  iHealthKit
//
//  Created by admin on 7/21/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbBirthDay;
@property (weak, nonatomic) IBOutlet UILabel *lbActivity;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@end
