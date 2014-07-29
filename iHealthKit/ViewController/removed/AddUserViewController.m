//
//  AddUserViewController.m
//  iHealthKit
//
//  Created by admin on 7/18/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "SettingsViewController.h"
#import "AddUserViewController.h"
#import "TrackingViewController.h"
#import "MyPickerView.h"

typedef enum {
    AddUserVCSections_Name = 0,
    AddUserVCSections_Gender,
    AddUserVCSections_Info
} AddUserVCSections;

typedef enum {
    PickerViewType_BirthDate = 0,
    PickerViewType_Height,
    PickerViewType_weight
} PickerViewType;

typedef enum {
    GenderType_Male = 0,
    GenderType_Female
} GenderType;

typedef enum {
    ViewMode_ViewInfo,
    ViewMode_AddUser
} ViewMode;

@interface AddUserViewController ()

@property NSInteger toggle;
@property NSInteger weight_Toggle;
@property NSInteger height_Toggle;
@property NSInteger birthDate_Toggle;
@property NSInteger pickerType;
@property (strong, nonatomic) MyPickerView* pickerView;
@property (strong, nonatomic) UIDatePicker* birthDatePicker;

@property int viewMode;

@property NSString* firstName;
@property NSString* lastName;
@property NSNumber* gender;
@property NSString* email;
@property NSDate* birthDate;
@property NSNumber* height;
@property NSNumber* weight;

@end

@implementation AddUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initEdit: (MyUser*) user {
    AddUserViewController* addVC = [[AddUserViewController alloc] init];
    addVC.viewMode = ViewMode_ViewInfo;
    //addVC.firstName = user.name;
    addVC.lastName = @"";
    addVC.gender = user.isMale;
#warning add email to coredata
    //addVC.email = user.email;
    
    addVC.birthDate = user.birthday;
    addVC.weight = user.weight;
    addVC.height = user.height;
    addVC.curUser = user;
    /*
    addVC.tfName.text = user.name;
    addVC.tfHeight.text = [NSString stringWithFormat:@"%f",[user.height floatValue]];
    addVC.tfWeight.text = [NSString stringWithFormat:@"%f",[user.weight floatValue]];
    addVC.datePicker.date = user.birthday;
    
    addVC.curUser = user;
     */
    return addVC;
}

-(id)initAdd {
    AddUserViewController* addVC = [[AddUserViewController alloc] init];
    addVC.viewMode = ViewMode_AddUser;
    
    return addVC;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //UITapGestureRecognizer * tapBackgournd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground)];
    //[tapBackgournd setNumberOfTapsRequired:1];
    //[self.view addGestureRecognizer:tapBackgournd];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    self.toggle = 0;
    self.height_Toggle = 0;
    self.weight_Toggle = 0;
    self.birthDate_Toggle = 0;
    
    self.pickerView = [[MyPickerView alloc] initWithFrame:(CGRect){{0,0}, 320, 180}];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.center = (CGPoint){160, 640};
    self.pickerView.hidden = YES;
    [self.view addSubview:self.pickerView];
    
    self.birthDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    [self.birthDatePicker setMaximumDate:[NSDate date]];
    [self.birthDatePicker setMinimumDate:[NSDate dateWithTimeIntervalSinceNow:(-1 * (160*365*24*60*60))]];
    [self.birthDatePicker setDatePickerMode:UIDatePickerModeDate];
    [self.birthDatePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    self.birthDatePicker.hidden = YES;
    [self.view addSubview:self.birthDatePicker];
    
    
    if (_viewMode == ViewMode_ViewInfo) {
        UIBarButtonItem* rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editUser)];
        [self.navigationItem setRightBarButtonItem:rightBarBtn];
        [self setTitle:@"Edit User"];
        
    }
    else {
        UIBarButtonItem* rightBarBtn;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunchComplete"]) {
            rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(addUser)];
        }
        else {
            rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addUser)];
        }
        [self.navigationItem setRightBarButtonItem:rightBarBtn animated:YES];
        [self setTitle:@"Add New User"];
    }
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.tableView addGestureRecognizer:tapGesture];
    self.tableView.userInteractionEnabled = YES;
    
    
}

- (void) tapBackground {
    [_tfHeight resignFirstResponder];
    [_tfWeight resignFirstResponder];
    [_tfName resignFirstResponder];
    [self.tableView endEditing:YES];
    [self hideView:_pickerView];
    [self hideView:_datePicker];
    
}
                                
- (void) addUser {
    BOOL isMale = (_segmentGender.selectedSegmentIndex == GenderType_Male) ? YES : NO;
    
    [CoreDataFuntions addNewUser:_firstName lastName:_lastName height:[_height floatValue] weight:[_weight floatValue] birthDate:_birthDate email:_email gender:isMale];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunchComplete"]) {
        SettingsViewController* settingVC = [[SettingsViewController alloc] init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddUser" object:self];
    
        TrackingViewController* trackingVC = [[TrackingViewController alloc] init];
        [self.navigationController pushViewController:trackingVC animated:YES];
    }
}

- (float) convertHeight: (float) height {
#warning implement later
    
    return height;
}

-(float) convertWeight: (float) weight {
#warning implement later
    
    return weight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AddUserVCSections_Name:
            return 2;
            break;
        case AddUserVCSections_Gender:
            return 1;
            break;
        case AddUserVCSections_Info:
            return 4;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifer = @"Cell";
    
                                      
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.section) {
        case AddUserVCSections_Name:{
            if (indexPath.row == 0) {
                cell.textLabel.text = @"First Name";
                UITextField* nameLabel = [[UITextField alloc] initWithFrame:CGRectMake(150, 0, cell.frame.size.width - 150, cell.frame.size.height)];
                nameLabel.placeholder = (_firstName == nil) ? @"First Name" : _firstName;
                cell.accessoryView = nameLabel;
            }
            else {
                cell.textLabel.text = @"Last Name";
                UITextField* nameLabel = [[UITextField alloc] initWithFrame:CGRectMake(150, 0, cell.frame.size.width - 150, cell.frame.size.height)];
                nameLabel.placeholder = (_lastName == nil) ? @"Last Name" : _lastName;
                cell.accessoryView = nameLabel;
            }
            break;
        }
        case AddUserVCSections_Gender: {
            UISegmentedControl* genderSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"", nil]];
            genderSegment.frame = CGRectMake(15, 5, cell.frame.size.width - 30, cell.frame.size.height - 10);
            [genderSegment setTitle:@"Male" forSegmentAtIndex:GenderType_Male];
            [genderSegment setTitle:@"Female" forSegmentAtIndex:GenderType_Female];
            genderSegment.selectedSegmentIndex = (_gender) ? [_gender intValue] : 0;
            cell.accessoryView = genderSegment;
            break;
        }
        case AddUserVCSections_Info: {
            UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, cell.frame.size.width - 150, cell.frame.size.height)];
            descriptionLabel.textColor = [UIColor grayColor];
            
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = @"E-Mail";
                    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(150, 0, cell.frame.size.width - 150, cell.frame.size.height)];
                    textField.placeholder = (_email == nil) ? @"Your email" : _email;
                    textField.borderStyle = UITextBorderStyleNone;
                    cell.accessoryView = textField;
                    break;
                }
                case 1 : {
                    cell.textLabel.text = @"Birth Date";
                    descriptionLabel.text = (_birthDate == nil) ? @"Your Birth Date" : [NSDateFormatter localizedStringFromDate:_birthDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
                    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(birthDateSelected)];
                    [tapGesture setNumberOfTapsRequired:1];
                    [tapGesture setNumberOfTouchesRequired:1];
                    [descriptionLabel addGestureRecognizer:tapGesture];
                    descriptionLabel.userInteractionEnabled = YES;

                    cell.accessoryView = descriptionLabel;
                    break;
                }
                case 2: {
                    cell.textLabel.text = @"Height";
                    descriptionLabel.text = (_height == nil) ? @"Your Height" : [self getHeightString];
                    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(heightSelected)];
                    [tapGesture setNumberOfTapsRequired:1];
                    [tapGesture setNumberOfTouchesRequired:1];
                    [descriptionLabel addGestureRecognizer:tapGesture];
                    descriptionLabel.userInteractionEnabled = YES;
                    cell.accessoryView = descriptionLabel;
                    break;
                }
                case 3: {
                    cell.textLabel.text = @"Weight";
                    descriptionLabel.text = (_weight == nil) ? @"Your Weight" : [self getWeightString];
                    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weightSelected)];
                    [tapGesture setNumberOfTapsRequired:1];
                    [tapGesture setNumberOfTouchesRequired:1];
                    [descriptionLabel addGestureRecognizer:tapGesture];
                    descriptionLabel.userInteractionEnabled = YES;
                    cell.accessoryView = descriptionLabel;
                }
                default:
                    break;
            }
        }
        default:
            break;
    }
    return cell;
}

- (void) birthDateSelected {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:AddUserVCSections_Info];
    
    
    
    if (_birthDate_Toggle == 0) {
        _birthDate_Toggle = 1;
        [self bringUpPickerView:indexPath withView:_birthDatePicker];
        
        if (_height_Toggle == 1) {
            [self heightSelected];
        }
        else if (_weight_Toggle == 1) {
            [self weightSelected];
        }
    }
    else {
        _birthDate_Toggle = 0;
        [self hideView:_birthDatePicker];
    }
}

- (void) heightSelected {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:2 inSection:AddUserVCSections_Info];
    
    if (self.birthDate_Toggle == 1) {
        [self birthDateSelected];
    }
    
    if (self.height_Toggle == 0) {
        if (self.weight_Toggle == 1) {
            _weight_Toggle = 0;
        }
        
        self.height_Toggle = 1;
        self.pickerType = PickerViewType_Height;
        
        self.pickerView.pickerData = [self getPickerHeightData];
        [self.pickerView reloadAllComponents];
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];]
        [self bringUpPickerView:indexPath withView:_pickerView];
    }
    else {
        self.height_Toggle = 0;
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self hideView:_pickerView];
    }
}

- (void) weightSelected {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:3 inSection:AddUserVCSections_Info];
    if (self.birthDate_Toggle == 1) {
        [self birthDateSelected];
    }
    
    
    
    if (self.weight_Toggle == 0) {
        if (self.height_Toggle == 1) {
            _height_Toggle = 0;
        }
        self.weight_Toggle = 1;
        self.pickerType = PickerViewType_weight;
        self.pickerView.pickerData = [self getPickerHeightData];
        [self.pickerView reloadAllComponents];
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];]
        [self bringUpPickerView:indexPath withView:_pickerView];
        
    }
    else {
        self.weight_Toggle = 0;
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self hideView:_pickerView];
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == AddUserVCSections_Gender) {
        return @"Gender";
    }
    else
        return nil;
}

#pragma mark Picker view delegate
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    MyPickerView* myPicker = (MyPickerView*) pickerView;
    switch (myPicker.pickerType) {
        case  PickerViewType_weight:
            _weight = [self getWeigthFromPickerView];
            break;
        case PickerViewType_Height:
            _height = [self getHeightFromPickerView];
            break;
        default:
            break;
    }
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
        case 1:
        case 2:
        case 4:
            return [NSString stringWithFormat:@"%d", row];
            break;
        
        case 3:
            return @".";
            break;
        case 5:
            switch (row) {
                case 0:
                    return (_pickerType == PickerViewType_Height) ? @"cm" : @"kg";
                    break;
                case 1:
                    return (_pickerType == PickerViewType_Height) ? @"ft" : @"lb";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return nil;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    //return 6;
    MyPickerView* myPicker = (MyPickerView*) pickerView;
    return [myPicker numberOfComponents];
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    /*switch (component) {
        case 0: //first digit
            return 4;
            break;
        case 1: //other digit
        case 2:
        case 4:
            return 10;
            break;
        
        case 3: //dot
            return 1;
            break;
        case 5://unit
            return 2;
            break;
        default:
            break;
    }
    return 0;*/
    MyPickerView* myPicker = (MyPickerView*) pickerView;
    return [[myPicker.pickerData objectAtIndex:component] intValue];
    
}

- (void) bringUpPickerView: (NSIndexPath*) indexPath withView: (UIView*) view{
    
    CGRect tableFrame = [self.tableView frame];
    
    CGRect pickerFrame = [view frame];
    tableFrame.size.height = self.view.frame.size.height - 64 - pickerFrame.size.height - 10;
    pickerFrame.origin.y = self.view.frame.size.height - pickerFrame.size.height;
    view.frame = CGRectMake(0, 700, pickerFrame.size.width, pickerFrame.size.height);
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.hidden = NO;
                         view.frame = pickerFrame;
                         [self.tableView setFrame:tableFrame];
                         [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                         
                     }completion:nil];
}

- (void) hideView: (UIView*) view {
    CGRect tableFrame = [self.tableView frame];
    CGRect pickerFrame = [view frame];
    pickerFrame.origin.y = 700;
    tableFrame.size.height = self.view.frame.size.height - 64;
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = pickerFrame;
                         self.tableView.frame = tableFrame;
    }completion:^(BOOL finished) {
        view.hidden = YES;
    }];
}

- (NSArray*) getPickerHeightData {
    NSArray* pickerData = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:10],[NSNumber numberWithInt:10],[NSNumber numberWithInt:1],[NSNumber numberWithInt:10],[NSNumber numberWithInt:2], nil];
    return pickerData;
}

- (NSArray*) getPickerWeightData {
    NSArray* pickerData = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:2],[NSNumber numberWithInt:10],[NSNumber numberWithInt:10],[NSNumber numberWithInt:1],[NSNumber numberWithInt:10],[NSNumber numberWithInt:2], nil];
    return pickerData;
}

- (void) dateChanged {
    
}

- (NSNumber*) getWeigthFromPickerView {
    float weight = [_pickerView selectedRowInComponent:0];
    weight = weight * 10 + [_pickerView selectedRowInComponent:1];
    weight = weight * 10 + [_pickerView selectedRowInComponent:2];
    weight = weight + [_pickerView selectedRowInComponent:4] / 10.0f;
    
    if ([_pickerView selectedRowInComponent:5] == 1) {
        weight = [self convertWeight:weight];
    }
    
    return [NSNumber numberWithFloat:weight];
}

- (NSNumber*) getHeightFromPickerView {
    float height = [_pickerView selectedRowInComponent:0];
    height = height * 10 + [_pickerView selectedRowInComponent:1];
    height = height * 10 + [_pickerView selectedRowInComponent:2];
    height = height + [_pickerView selectedRowInComponent:4] / 10.0f;
    
    if ([_pickerView selectedRowInComponent:5] == 1) {
        height = [self convertHeight:height];
    }
    
    return [NSNumber numberWithFloat:height];
}

- (NSString*) getHeightString {
    NSUserDefaults* preference = [NSUserDefaults standardUserDefaults];
    if ([preference integerForKey:@"DistanceUnit"] == 1) {
        _height = [NSNumber numberWithFloat: [self convertHeight: [_height floatValue]]];
        return [NSString stringWithFormat: @"%.2f ft", [_height floatValue]];
    }
    return [NSString stringWithFormat: @"%.2f cm", [_height floatValue]];
}

- (NSString*) getWeightString {
    NSUserDefaults* preference = [NSUserDefaults standardUserDefaults];
    if ([preference integerForKey:@"WeightUnit"] == 1) {
        _height = [NSNumber numberWithFloat: [self convertWeight:[_weight floatValue]]];
        return [NSString stringWithFormat: @"%.2f lb", [_height floatValue]];
    }
    return [NSString stringWithFormat: @"%.2f kg", [_height floatValue]];
}

- (void) updateUserInfo {
    //_curUser.name = _firstName;
    _curUser.birthday = _birthDate;
    _curUser.weight = _weight;
    _curUser.height = _height;
    _curUser.isMale = _gender;
}

@end
