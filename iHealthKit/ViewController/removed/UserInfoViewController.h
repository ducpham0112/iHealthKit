//
//  UserInfoViewController.h
//  iHealthKit
//
//  Created by admin on 7/18/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUser.h"
#import "MyRoute.h"

@interface UserInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbWeight;
@property (weak, nonatomic) IBOutlet UILabel *lbHeight;
@property (weak, nonatomic) IBOutlet UILabel *lbActivity;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentGender;

@property (strong, nonatomic) MyUser* user;
@property (weak, nonatomic) IBOutlet UIButton *btnLogIn;

@property (nonatomic) BOOL isSignInMode;

- (id) initSignInMode: (MyUser*) user;
- (id) initViewMode: (MyUser*) user;
- (IBAction)btnClicked:(id)sender;

@end
