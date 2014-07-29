//
//  UserInfoViewController.m
//  iHealthKit
//
//  Created by admin on 7/18/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "UserInfoViewController.h"
#import "AddUserViewController.h"
#import "ListUserTableViewController.h"
#import "TrackingViewController.h"
#import "UserViewController.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initViewMode:(MyUser *)user {
    UserInfoViewController* userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.user = user;
    userInfoVC.isSignInMode = NO;
    return userInfoVC;
}

- (id) initSignInMode:(MyUser *)user {
    UserInfoViewController* userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.user = user;
    userInfoVC.isSignInMode = YES;
    return userInfoVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_user == nil) {
        _user = [CoreDataFuntions getCurUser];
        if (_user) {
            _user = [CoreDataFuntions getUserAtIndex:0];
        }
    }
    [self displayInfo];
    [self setTitle:@"User Information"];
    
    if (!_isSignInMode) {
        [_btnLogIn setTitle:[NSString stringWithFormat:@"Not %@?", _user.firstName] forState:UIControlStateNormal];
    }
    else {
        [_btnLogIn setTitle:@"Login" forState:UIControlStateNormal];
        UIBarButtonItem* rightBarBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editUser)];
        [self.navigationItem setRightBarButtonItem:rightBarBtn];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfo) name:@"EditUser" object:nil];
}

- (void) editUser {
    UserViewController* editUserVC = [[UserViewController alloc] initEdit:_user];
    [self.navigationController pushViewController:editUserVC animated:YES];
}

- (void) displayInfo {
    _lbName.text = _user.firstName;
    [_lbName sizeToFit];
    _lbHeight.text = [NSString stringWithFormat:@"%.1f", [_user.height floatValue]];
    [_lbHeight sizeToFit];
    _lbWeight.text = [NSString stringWithFormat:@"%.1f", [_user.weight floatValue]];
    [_lbWeight sizeToFit];
    _lbActivity.text = [NSString stringWithFormat:@"%d", [[_user.routeHistory allObjects] count]];
    [_lbActivity sizeToFit];
    
    if ([_user.isMale boolValue]) {
        _segmentGender.selectedSegmentIndex = 0;
    }
    else {
        _segmentGender.selectedSegmentIndex = 1;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnClicked:(id)sender {
    if (_isSignInMode) {
        MyUser* curUser = [CoreDataFuntions getCurUser];
        if (_user != curUser) {
            curUser.isCurrentUser = [NSNumber numberWithBool:NO];
            _user.isCurrentUser = [NSNumber numberWithBool:YES];
            
        }
        TrackingViewController* trackingVC = [[TrackingViewController alloc] init];
        [self.navigationController pushViewController:trackingVC animated:YES];
    }
    else {
        ListUserTableViewController* listUserVC = [[ListUserTableViewController alloc] init];
        [self.navigationController pushViewController:listUserVC animated:YES];
    }
}
@end
