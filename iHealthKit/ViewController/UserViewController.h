//
//  UserViewController.h
//  iHealthKit
//
//  Created by admin on 7/24/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

- (id) initEdit: (MyUser*) user ;
- (id) initAdd;
- (id) initLogIn: (MyUser*) user;

@end
