//
//  UserNameCell.h
//  iHealthKit
//
//  Created by admin on 8/10/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfo_NameCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@end
