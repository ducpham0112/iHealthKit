//
//  UserViewController.m
//  iHealthKit
//
//  Created by admin on 7/24/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "UserViewController.h"
#import "SettingsViewController.h"
#import "TrackingViewController.h"
#import "View/MyPickerView.h"
//#import "CellWithAdditionalLabel.h"
//#import "CellWithTextField.h"
#import "HistoryViewController.h"
#import "View/UserInfo_NameCell.h"
#import "View/UserInfo_GenderCell.h"
#import "View/UserInfo_EmailCell.h"
#import "View/UserInfo_PickerCell.h"

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
    ViewMode_AddUser,
    ViewMode_LogIn
} ViewMode;

typedef enum {
    RowInSectionInfo_email = 0,
    RowInSectionInfo_birthDate,
    RowInSectionInfo_height,
    RowInSectionInfo_weight
} RowInSectionInfo;

@interface UserViewController ()

@property (strong, nonatomic) UITableView* tableView;
//@property NSInteger pickerType;
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
@property UIImage* avatar;

@property MyUser* curUser;

@property int frameHeight;
@property int pickerHeight;
@property int tableHeight;

@property CGRect pickerFrame;
@property CGRect pickerHideFrame;

@property BOOL isFirstLaunch;

@property NSInteger toggle;
@property NSInteger weight_Toggle;
@property NSInteger height_Toggle;
@property NSInteger birthDate_Toggle;

@property BOOL keyboardShown;
@property CGFloat keyboardOverlap;

@end

@implementation UserViewController


-(id)initEdit: (MyUser*) user {
    UserViewController* userVC = [[UserViewController alloc] init];

    userVC.viewMode = ViewMode_ViewInfo;
    userVC.firstName = user.firstName;
    userVC.lastName = user.lastName;
    userVC.gender = user.isMale;
    userVC.email = user.email;
    
    UIImage* avatar = nil;
    if (user.avatar != nil) {
        avatar = [[UIImage alloc] initWithData:user.avatar];
    }
    userVC.avatar = avatar;
    
    userVC.birthDate = user.birthday;
    userVC.weight = user.weight;
    userVC.height = user.height;
    userVC.curUser = user;

    return userVC;
}

-(id) initLogIn:(MyUser *)user {
    UserViewController* userVC = [[UserViewController alloc] initEdit:user];
    userVC.viewMode = ViewMode_LogIn;
    return userVC;
}

-(id)initAdd {
    UserViewController* userVC = [[UserViewController alloc] init];

    userVC.viewMode = ViewMode_AddUser;
    userVC.firstName = nil;
    userVC.lastName = nil;
    userVC.gender = nil;
    userVC.email = nil;
    
    userVC.birthDate = nil;
    userVC.weight = nil;
    userVC.height = nil;
    userVC.curUser = nil;
    return userVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _isFirstLaunch = ([[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunchComplete"]) ? NO : YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserInfo_NameCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userNameCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserInfo_PickerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"pickerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserInfo_GenderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"genderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserInfo_EmailCell"  bundle:[NSBundle mainBundle]]forCellReuseIdentifier:@"emailCell"];
    
    [self initPickers];
    [self setupBarButton];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground)];
    [self.tableView addGestureRecognizer:tapGesture];
    self.tableView.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources thatcan be recreated.
}

- (void) login {
    [CoreDataFuntions switchUser:_curUser];
    HistoryViewController* historyVC = [[HistoryViewController alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"UserChanged" object:self];
}

#pragma mark - setup bar button
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) setRightBarButton {
    if (_viewMode == ViewMode_ViewInfo) {
        if (self.navigationItem.rightBarButtonItem == nil) {
            UIBarButtonItem* rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];
            [self.navigationItem setRightBarButtonItem:rightBarBtn animated:YES];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case AddUserVCSections_Name:
            return 1;
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 94;
    }
    else {
        return 44;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case AddUserVCSections_Name:{
            UserInfo_NameCell* cell = [tableView dequeueReusableCellWithIdentifier:@"userNameCell"];
            if (cell == nil) {
                cell = [[UserInfo_NameCell alloc] init];
            }
            cell.tfFirstName.text = _firstName;
            cell.tfLastName.text = _lastName;
            
            
            if (_avatar == nil) {
                if ([_curUser.isMale integerValue] == 0) {
                    cell.imgAvatar.image = [UIImage imageNamed:@"avatar_male.jpg"];
                } else {
                    cell.imgAvatar.image = [UIImage imageNamed:@"avatar_female.jpg"];
                }
            } else {
                cell.imgAvatar.image = _avatar;
            }
            
            if (_viewMode != ViewMode_LogIn) {
                cell.tfFirstName.enabled = YES;
                cell.tfLastName.enabled = YES;
                [cell.tfFirstName addTarget:self action:@selector(updateFirstName:) forControlEvents:UIControlEventEditingDidEnd];
                [cell.tfLastName addTarget:self action:@selector(updateLastName:) forControlEvents:UIControlEventEditingDidEnd];
                UITapGestureRecognizer* tapAvatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateAvatar:)];
                tapAvatarGesture.numberOfTapsRequired = 1;
                tapAvatarGesture.numberOfTouchesRequired = 1;
                [cell.imgAvatar addGestureRecognizer:tapAvatarGesture];
            }
            
            return  cell;
            break;
        }
        case AddUserVCSections_Gender: {
            UserInfo_GenderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"genderCell"];
            if (cell == nil) {
                    cell = [[UserInfo_GenderCell alloc] init];
            }
            
            if (_gender != nil) {
                cell.genderSegment.selectedSegmentIndex = [_gender integerValue];
            }
            
            if (_viewMode != ViewMode_LogIn) {
                cell.genderSegment.userInteractionEnabled = YES;
                [cell.genderSegment addTarget:self action:@selector(updateGender:) forControlEvents:UIControlEventValueChanged];
            }
            return cell;
            break;
            
        }
        case AddUserVCSections_Info: {
            switch (indexPath.row) {
                case RowInSectionInfo_email: {
                    UserInfo_EmailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"emailCell"];
                    if (cell == nil) {
                        cell = [[UserInfo_EmailCell alloc] init];
                    }
                    
                    cell.tfValue.text = _email;
                    if (_viewMode != ViewMode_LogIn) {
                        cell.tfValue.enabled = YES;
                        [cell.tfValue addTarget:self action:@selector(updateEmail:) forControlEvents:UIControlEventEditingDidEnd];
                    }
                    return cell;
                    break;
                }
                case RowInSectionInfo_birthDate: {
                    UserInfo_PickerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
                    
                    if (cell == nil) {
                        cell = [[UserInfo_PickerCell alloc] init];
                    }
                    
                    cell.lbDescription.text = @"Birth Date";
                    
                    if (_birthDate == nil) {
                        cell.lbValue.text = @"Your Birth Date";
                        cell.lbValue.textColor = [CommonFunctions lightGrayColor];
                    }
                    else {
                        cell.lbValue.text = [NSDateFormatter localizedStringFromDate:_birthDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                        cell.lbValue.textColor = [UIColor blackColor];
                    }
                    
                    if (_viewMode != ViewMode_LogIn) {
                        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(birthDateSelected)];
                        [cell.lbValue addGestureRecognizer:tapGesture];
                    }
                    
                    return cell;
                    break;
                }
                    
                case RowInSectionInfo_height: {
                    UserInfo_PickerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
                    
                    if (cell == nil) {
                        cell = [[UserInfo_PickerCell alloc] init];
                    }
                    
                    
                    cell.lbDescription.text = @"Height";
                    if (_height == nil) {
                        cell.lbValue.text = @"Your Height";
                        cell.lbValue.textColor = [CommonFunctions lightGrayColor];
                    }
                    else {
                        cell.lbValue.text = [self getHeightString];
                        cell.lbValue.textColor = [UIColor blackColor];
                    }
                    
                    if (_viewMode != ViewMode_LogIn) {
                        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(heightSelected)];
                        [cell.lbValue addGestureRecognizer:tapGesture];
                    }
                    
                    return cell;
                    break;
                }
                case RowInSectionInfo_weight: {
                    UserInfo_PickerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
                    
                    if (cell == nil) {
                        cell = [[UserInfo_PickerCell alloc] init];
                    }
                    
                    cell.lbDescription.text = @"Weight";
                    if (_weight == nil) {
                        cell.lbValue.text = @"Your Weight";
                        cell.lbValue.textColor = [CommonFunctions lightGrayColor];
                    }
                    else {
                        cell.lbValue.text = [self getWeightString];
                        cell.lbValue.textColor = [UIColor blackColor];
                    }
                    
                    if (_viewMode != ViewMode_LogIn) {
                        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weightSelected)];
                        [cell.lbValue addGestureRecognizer:tapGesture];
                    }
                    
                    return cell;
                    break;
                }
                default:
                    break;
            }
        }
        default:
            break;
    }
    return nil;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* headerStr;
    switch (section) {
        case AddUserVCSections_Name:
            headerStr = @"User Name";
            break;
        case AddUserVCSections_Gender:
            headerStr = @"Gender";
            break;
        case AddUserVCSections_Info:
            headerStr = @"Details";
            break;
        default:
            headerStr = @"";
            break;
    }
    return headerStr;
}

#pragma mark - Picker view data source
- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString* titleStr;
    MyPickerView* myPicker = (MyPickerView*) pickerView;
    switch (component) {
        case 0: case 1: case 2: case 4: {
            titleStr = [NSString stringWithFormat:@"%d", row];
            break;
        }
        case 3: {
            titleStr = @".";
            break;
        }
        case 5: {
            titleStr = [NSString stringWithFormat:@"%@",[[myPicker.pickerData objectAtIndex:component] objectAtIndex:row]];
            break;
        }
        default:
            titleStr = @"";
            break;
    }
    return titleStr;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    MyPickerView* myPicker = (MyPickerView*) pickerView;
    return [myPicker numberOfComponents];
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    MyPickerView* myPicker = (MyPickerView*) pickerView;
    if (component == 5) {
        return [[myPicker.pickerData objectAtIndex:component] count];
    }
    else {
        return [[myPicker.pickerData objectAtIndex:component] intValue];
    }
}

#pragma mark - show/hide picker view
- (void) showView: (UIView*) view cellIndexPath: (NSIndexPath*) indexPath animated: (BOOL) animated{
    NSTimeInterval delay = 0;
    if (_keyboardShown) {
        [self.tableView endEditing:YES];
        delay += 0.5;
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = _tableHeight - _pickerHeight;
    
    if (animated) {
        [UIView animateWithDuration:0.5f
                              delay:delay
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             view.hidden = NO;
                             view.frame = _pickerFrame;
                             self.tableView.frame = tableFrame;
                             [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                         } completion:nil];
    }
    else {
        view.hidden = NO;
        view.frame = _pickerFrame;
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void) hideView: (UIView*) view animated: (BOOL) animated{
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = _tableHeight;
    
    if (animated) {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             view.frame = _pickerHideFrame;
                             self.tableView.frame = tableFrame;
                         }completion:^ (BOOL finished) {
                             view.hidden = YES;
                         }];
    }
    else {
        view.frame = _pickerHideFrame;
        view.hidden = YES;
    }
}

- (BOOL) hideAllPicker: (BOOL) animated {
    BOOL check = NO;
    if (_toggle != 0) {
        if (_height_Toggle != 0 || _weight != 0) {
            [self hideView:_pickerView animated:animated];
            check = YES;
        }
        if (_birthDate_Toggle != 0) {
            [self hideView:_birthDatePicker animated:animated];
            check = YES;
        }
    }
    _toggle = 0;
    _birthDate_Toggle = 0;
    _weight_Toggle = 0;
    _height_Toggle = 0;
    return check;
    
}

- (NSArray*) getPickerHeightData {
    NSString* unit = ([[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"] == 1) ? @"ft" : @"cm";
    NSMutableArray* data = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:10],[NSNumber numberWithInt:10],[NSNumber numberWithInt:1],[NSNumber numberWithInt:10], [NSArray arrayWithObjects:unit, nil], nil];
    return data;
}

- (NSArray*) getPickerWeightData {
    NSString* unit = ([[NSUserDefaults standardUserDefaults] integerForKey:@"WeightUnit"] == 1) ? @"lb" : @"kg";
    NSMutableArray* data = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:10],[NSNumber numberWithInt:10],[NSNumber numberWithInt:1],[NSNumber numberWithInt:10], [NSArray arrayWithObjects:unit, nil], nil];
    return data;
}

#pragma mark - table view interaction
- (void) birthDateSelected {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:RowInSectionInfo_birthDate inSection:AddUserVCSections_Info];
    if (_toggle == 0) {
        [self setSelectedBirthDateInPickerView];
        [self showView:_birthDatePicker cellIndexPath:indexPath animated:YES];
        _toggle = 1;
        _birthDate_Toggle = 1;
    }
    else {
        if (_birthDate_Toggle == 1) {
            [self hideView:_birthDatePicker animated:YES];
            _birthDate_Toggle = 0;
            _toggle = 0;
        }
        else {
            [self setSelectedBirthDateInPickerView];
            [self showView:_birthDatePicker cellIndexPath:indexPath animated:NO];
            _birthDate_Toggle = 1;
            
            [self hideView:_pickerView animated:NO];
            _height_Toggle = 0;
            _weight_Toggle = 0;
        }
    }
}

- (void) heightSelected {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:RowInSectionInfo_height inSection:AddUserVCSections_Info];
    
    if (_toggle == 0) {
        _pickerView.pickerData = [self getPickerHeightData];
        [_pickerView reloadAllComponents];
        [self setSelectedHeightInPickerView];
        [self showView:_pickerView cellIndexPath:indexPath animated:YES];
        _toggle = 1;
        _height_Toggle = 1;
    }
    else {
        if (_height_Toggle == 1) {
            [self hideView:_pickerView animated:YES];
            _height_Toggle = 0;
            _toggle = 0;
        }
        else {
            _pickerView.pickerData = [self getPickerHeightData];
            [_pickerView reloadAllComponents];
            [self setSelectedHeightInPickerView];
            [self showView:_pickerView cellIndexPath:indexPath animated:NO];
            
            if (_birthDate_Toggle == 1) {
                [self hideView:_birthDatePicker animated:NO];
            }
            
            _height_Toggle = 1;
            _birthDate_Toggle = 0;
            _weight_Toggle = 0;
        }
    }
}

- (void) weightSelected {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:RowInSectionInfo_weight inSection:AddUserVCSections_Info];
    
    if (_toggle == 0) {
        _pickerView.pickerData = [self getPickerWeightData];
        [_pickerView reloadAllComponents];
        [self setSelectedWeightInPickerView];
        _toggle = 1;
        _weight_Toggle = 1;
        [self showView:_pickerView cellIndexPath:indexPath animated:YES];
    }
    else {
        if (_weight_Toggle == 1) {
            [self hideView:_pickerView animated:YES];
            _weight_Toggle = 0;
            _toggle = 0;
        }
        else {
            _pickerView.pickerData = [self getPickerWeightData];
            [_pickerView reloadAllComponents];
            [self setSelectedWeightInPickerView];
            [self showView:_pickerView cellIndexPath:indexPath animated:NO];
            
            if (_birthDate_Toggle == 1) {
                [self hideView:_birthDatePicker animated:NO];
            }
            
            _weight_Toggle = 1;
            _birthDate_Toggle = 0;
            _height_Toggle = 0;
        }
    }
}

- (void) setSelectedBirthDateInPickerView {
    if (_birthDate == nil) {
        _birthDate = [CommonFunctions dateFromString:@"01/12/1990" withFormat:nil];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:RowInSectionInfo_birthDate inSection:AddUserVCSections_Info] ]withRowAnimation:UITableViewRowAnimationFade];
    }
    [_birthDatePicker setDate:_birthDate animated:NO];
}

- (void) setSelectedWeightInPickerView {
    if (_weight == nil) {
        _weight = [NSNumber numberWithFloat:70.0f];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:RowInSectionInfo_weight inSection:AddUserVCSections_Info] ]withRowAnimation:UITableViewRowAnimationFade];
    }
    
    int digit;
    float weight = [CommonFunctions convertWeight:[_weight floatValue]];
    int remain = trunc(weight);
    //decimal
    
    digit = [[NSString stringWithFormat:@"%.1f", (weight - remain)] floatValue] * 10;
    [_pickerView selectRow:(int)digit inComponent:4 animated:NO];
    digit = remain % 10;
    remain /= 10;
    [_pickerView selectRow:digit inComponent:2 animated:NO];
    digit = remain % 10;
    remain /= 10;
    [_pickerView selectRow:digit inComponent:1 animated:NO];
    [_pickerView selectRow:remain inComponent:0 animated:NO];
}

- (void) setSelectedHeightInPickerView {
    if (_height == nil) {
        _height = [NSNumber numberWithFloat:170.0f];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:RowInSectionInfo_height inSection:AddUserVCSections_Info] ]withRowAnimation:UITableViewRowAnimationFade];
    }
    
    int digit;
    
    float height = [CommonFunctions convertHeight:[_height floatValue]];
    int remain = trunc(height);
    //decimal
    
    digit = [[NSString stringWithFormat:@"%.1f",(height - remain)] floatValue] * 10;
    [_pickerView selectRow:digit inComponent:4 animated:NO];
    digit = remain % 10;
    remain /= 10;
    [_pickerView selectRow:digit inComponent:2 animated:NO];
    digit = remain % 10;
    remain /= 10;
    [_pickerView selectRow:digit inComponent:1 animated:NO];
    [_pickerView selectRow:remain inComponent:0 animated:NO];
}


#pragma mark - date picker user interation
- (void) updateBirthDate: (id) sender{
    _birthDate = [_birthDatePicker date];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:RowInSectionInfo_birthDate inSection:AddUserVCSections_Info]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_height_Toggle == 1) {
        [self updateHeight];
    }
    if (_weight_Toggle == 1) {
        [self updateWeight];
    }
    
}

- (void) updateHeight {
    int unit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    
    _height = [NSNumber numberWithFloat:[self getNumberFromPicker]];
    if (unit == 1) {
        _height = [NSNumber numberWithFloat:[CommonFunctions convertHeightToCm:[_height floatValue]]];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:RowInSectionInfo_height inSection:AddUserVCSections_Info]] withRowAnimation:UITableViewRowAnimationFade];
    [self setRightBarButton];
}

- (void) updateWeight {
    int unit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    
    _weight = [NSNumber numberWithFloat:[self getNumberFromPicker]];
    if (unit == 1) {
        _weight = [NSNumber numberWithFloat:[CommonFunctions convertWeightToKg:[_weight floatValue]]];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:RowInSectionInfo_weight inSection:AddUserVCSections_Info]] withRowAnimation:UITableViewRowAnimationFade];
    [self setRightBarButton];
}

- (void) updateAvatar: (id) sender {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.navigationBar.tintColor = [CommonFunctions navigationBarColor];
    
    //[self.navigationController pushViewController:imagePicker animated:YES];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _avatar = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self setRightBarButton];
    [self.tableView reloadData];
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateFirstName: (id) sender {
    UITextField* textField = (UITextField*) sender;
    _firstName = textField.text;
    [self setRightBarButton];
}
- (void) updateLastName: (id) sender {
    UITextField* textField = (UITextField*) sender;
    _lastName = textField.text;
    [self setRightBarButton];
}
- (void) updateEmail: (id) sender {
    UITextField* textField = (UITextField*) sender;
    _email = textField.text;
    [self setRightBarButton];
}
- (void) updateGender: (id) sender {
    UISegmentedControl* segmentControler = (UISegmentedControl*) sender;
    _gender = [NSNumber numberWithInteger:segmentControler.selectedSegmentIndex];
    [self setRightBarButton];
}

- (float) getNumberFromPicker {
    float height = [_pickerView selectedRowInComponent:0];
    height = height * 10 + [_pickerView selectedRowInComponent:1];
    height = height * 10 + [_pickerView selectedRowInComponent:2];
    height = height + [_pickerView selectedRowInComponent:4] / 10.0f;
    
    return height;
}

#pragma mark - keyboard show/hide handling
/*- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height -= kbFrame.size.height;
    
}*/

- (void)keyboardWillShow:(NSNotification *)aNotification
{
  
    if (_keyboardShown)
        return;
    
    _keyboardShown = YES;
    
    // Get the keyboard size
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    // Get the keyboard's animation details
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    // Determine how much overlap exists between tableView and the keyboard
    CGRect tableFrame = tableView.frame;
    CGFloat tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height;
    _keyboardOverlap = tableLowerYCoord - keyboardRect.origin.y;
    if(self.inputAccessoryView && _keyboardOverlap>0)
    {
        CGFloat accessoryHeight = self.inputAccessoryView.frame.size.height;
        _keyboardOverlap -= accessoryHeight;
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
    }
    
    if(_keyboardOverlap < 0)
        _keyboardOverlap = 0;
    
    if(_keyboardOverlap != 0)
    {
        tableFrame.size.height -= _keyboardOverlap;
        
        NSTimeInterval delay = 0;
        
        if(keyboardRect.size.height)
        {
            delay = (1 - _keyboardOverlap/keyboardRect.size.height)*animationDuration;
            animationDuration = animationDuration * _keyboardOverlap/keyboardRect.size.height;
        }
        
        if ([self hideAllPicker:NO]) {
            delay += 1.0f;
        }
        
        [UIView animateWithDuration:1.0f delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             tableView.frame = tableFrame;
                         }
                         completion:^(BOOL finished){
                             [self tableAnimationEnded];
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if(!_keyboardShown)
        return;
    
    _keyboardShown = NO;
    
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    if(self.inputAccessoryView)
    {
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    if(_keyboardOverlap == 0)
        return;
    
    // Get the size & animation details of the keyboard
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height = _tableHeight;
    
    if(keyboardRect.size.height)
        animationDuration = animationDuration * _keyboardOverlap/keyboardRect.size.height;
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ tableView.frame = tableFrame; }
                     completion:nil];
}

- (void) tableAnimationEnded
{
    // Scroll to the active cell
    NSIndexPath* activeCellIndexPath = [[self.tableView indexPathsForSelectedRows] lastObject];
    if(activeCellIndexPath)
    {
        [self.tableView scrollToRowAtIndexPath:activeCellIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //[self.tableView selectRowAtIndexPath:activeCellIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

#pragma user define function
- (void) tapBackground {
    [self.tableView endEditing:YES];
    [self hideAllPicker:YES];
}


- (void) deleteUser {
    if ([CoreDataFuntions deleteUser:_curUser]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ListUserChanged" object:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) addNewUser {
    if (_firstName == nil) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please enter your first name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_lastName == nil) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please enter your last name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_birthDate == nil) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please choos your birth date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_height == nil) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please choose your height" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_weight == nil) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please choose your weight" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_gender == nil) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please choose your gender" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSData* avatarData = nil;
    if (_avatar != nil) {
        avatarData = UIImagePNGRepresentation(_avatar);
    }
    
    [CoreDataFuntions saveNewUser:_firstName lastName:_lastName height:_height weight:_weight birthDate:_birthDate email:_email gender:_gender avatar:avatarData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserChanged" object:self];
    
    if (_isFirstLaunch) {
        [CommonFunctions setupDrawer];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLaunchComplete"];
    }
    else {
        TrackingViewController* trackingVC = [[TrackingViewController alloc] init];
        [CommonFunctions showStatusBarAlert:[NSString stringWithFormat:@"User %@ %@ has been added.", _firstName, _lastName] duration:2.0f backgroundColor:[CommonFunctions greenColor]];
        
        [self.navigationController pushViewController:trackingVC animated:YES];
    }
}

- (NSString*) getHeightString {
    NSUserDefaults* preference = [NSUserDefaults standardUserDefaults];
    NSString* unitString;
    float convertedHeight;
    if ([preference integerForKey:@"DistanceType"] == 1) {
        unitString = @"ft";
        convertedHeight = [CommonFunctions convertHeightToFt:[_height floatValue]];
    }
    else {
        unitString = @"cm";
        convertedHeight = [_height floatValue];
    }
    
    return [NSString stringWithFormat:@"%.1f %@", convertedHeight, unitString];
}

- (NSString*) getWeightString {
    NSUserDefaults* preference = [NSUserDefaults standardUserDefaults];
    NSString* unitString;
    float convertedWeight;
    if ([preference integerForKey:@"WeightUnit"] == 1) {
        unitString = @"lb";
        convertedWeight = [CommonFunctions convertWeightToLb:[_weight floatValue]];
    }
    else {
        unitString = @"kg";
        convertedWeight = [_weight floatValue];
    }
    
    return [NSString stringWithFormat:@"%.1f %@", convertedWeight, unitString];
}

- (void) saveChanges {
    _curUser.firstName = _firstName;
    _curUser.lastName = _lastName;
    _curUser.isMale = _gender;
    _curUser.email = _email;
    _curUser.birthday = _birthDate;
    _curUser.height = _height;
    _curUser.weight = _weight;
    
    NSData* avatarData = nil;
    if (_avatar != nil) {
        avatarData = UIImagePNGRepresentation(_avatar);
    }
    _curUser.avatar = avatarData;
    
    [CoreDataFuntions saveContent];
    
    [CommonFunctions showStatusBarAlert:@"User Infomation has been updated." duration:2.0f backgroundColor:[CommonFunctions greenColor]];
    
    self.title = [CoreDataFuntions fullName:_curUser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserChanged" object:self];
    [self.navigationItem setRightBarButtonItem:nil];
    
}

- (void) initPickers {
    
    _frameHeight = self.view.frame.size.height;
    _pickerHeight = 180;
    _tableHeight = self.tableView.frame.size.height;
    
    _pickerFrame = CGRectMake(0, self.view.frame.size.height - 180, self.view.frame.size.width, 180);
    _pickerHideFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 180);
    
    _pickerView = [[MyPickerView alloc] initWithFrame:_pickerHideFrame];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.hidden = YES;
    [_pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_pickerView];
    
    _birthDatePicker = [[UIDatePicker alloc] initWithFrame:_pickerHideFrame];
    [_birthDatePicker setDatePickerMode:UIDatePickerModeDate];
    [_birthDatePicker setMinimumDate:[CommonFunctions dateFromString:@"01/01/1900" withFormat:nil]];
    [_birthDatePicker setMaximumDate:[CommonFunctions dateFromString:@"31/12/2010" withFormat:nil]];
    [_birthDatePicker addTarget:self action:@selector(updateBirthDate:) forControlEvents:UIControlEventValueChanged];
    [_birthDatePicker setBackgroundColor:[UIColor whiteColor]];
    _birthDatePicker.hidden = YES;
    [self.view addSubview:_birthDatePicker];
}

- (void) setupBarButton {
    if (_viewMode == ViewMode_ViewInfo) {
        [self setTitle:[NSString stringWithFormat:@"%@", [CoreDataFuntions fullName:_curUser]]];
        
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    }
    else if (_viewMode == ViewMode_LogIn) {
        [self setTitle:[NSString stringWithFormat:@"%@", [CoreDataFuntions fullName:_curUser]]];
        
        UIBarButtonItem* loginBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(login)];
        UIBarButtonItem* deleteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteUser)];
        
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:loginBtn, deleteBtn, nil]];
    }
    else {
        [self setTitle:@"New User"];
        UIBarButtonItem* rightBarBtn;
        
        rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addNewUser)];
        
        [self.navigationItem setRightBarButtonItem:rightBarBtn];
    }
}

@end
