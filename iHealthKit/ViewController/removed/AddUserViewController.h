//
//  AddUserViewController.h
//  iHealthKit
//
//  Created by admin on 7/18/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *tfHeight;
@property (weak, nonatomic) IBOutlet UITextField *tfWeight;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentGender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL isEdit;

@property (nonatomic, strong) MyUser* curUser;

-(id) initEdit: (MyUser*) user;
-(id) initAdd;

@end
