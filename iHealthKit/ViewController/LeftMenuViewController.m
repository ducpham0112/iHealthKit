//
//  LeftMenuTableViewController.m
//  iHealthKit
//
//  Created by admin on 7/18/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "HistoryViewController.h"
#import "TrackingViewController.h"
#import "SettingsViewController.h"
#import "ListUserViewController.h"
#import "UserViewController.h"
#import "MyNavigationViewController.h"
#import "View/LeftMenuCell.h"
#import "View/LeftMenuHeaderCell.h"

typedef enum {
    //MenuRows_UserInfo,
    MenuRows_Activity = 0,
    MenuRows_History,
    MenuRows_Settings,
    MenuRows_ChangeUser

}MenuRows;

@interface LeftMenuViewController ()

@property NSIndexPath* selectedRow;

@end

@implementation LeftMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftMenuCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"leftMenuCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftMenuHeaderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"leftMenuHeaderCell"];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[CommonFunctions lightGrayColor]];
    [self.tableView setBounces:NO];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate) name:@"UserChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate) name:@"HistoryChanged" object:nil];
    
}

- (void) viewWillAppear:(BOOL)animated  {
   /* if (_selectedRow) {
        LeftMenuCell* selectedCell = (LeftMenuCell*)[self.tableView cellForRowAtIndexPath:_selectedRow];
        selectedCell.backgroundColor = [CommonFunctions lightGrayColor];
    }*/
}

- (void) userInfoUpdate {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            static NSString* CellIdentifier = @"leftMenuHeaderCell";
            LeftMenuHeaderCell* cell = (LeftMenuHeaderCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[LeftMenuHeaderCell alloc] init];
            }
            MyUser* curUser = [CoreDataFuntions curUser];
            cell.lbName.text = [CoreDataFuntions fullName:curUser];
            
            cell.lbAge.text = [NSString stringWithFormat:@"Age: %d", [CommonFunctions datePart:[NSDate date] withPart:DatePartType_year] - [CommonFunctions datePart:curUser.birthday withPart:DatePartType_year]];
            
            cell.lbActivity.text = [NSString stringWithFormat:@"Activities: %d", [[curUser.routeHistory allObjects] count]];
            
            if (curUser.avatar != nil) {
                cell.imgAvatar.image = [[UIImage alloc] initWithData:curUser.avatar];
            } else {
                if ([curUser.isMale integerValue] == 0) {
                    cell.imgAvatar.image = [UIImage imageNamed:@"avatar_male.jpg"];
                } else {
                    cell.imgAvatar.image = [UIImage imageNamed:@"avatar_female.jpg"];
                }
            }
            return cell;
            break;
        }
        case 1: {
            static NSString *CellIdentifier = @"leftMenuCell";
            
            LeftMenuCell* cell = (LeftMenuCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[LeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            switch (indexPath.row) {
                /*case MenuRows_UserInfo:
                    cell.lbDescription.text = @"User Information";
                    [cell.imgView setImage:[UIImage imageNamed:@"icon_UserInfo.png"]];
                    [cell.imgView setBackgroundColor:[CommonFunctions greenColor]];
                    break;*/
                case MenuRows_Activity:
                    cell.lbDescription.text = @"Activity";
                    [cell.imgView setImage:[UIImage imageNamed:@"icon_Activity.png"]];
                    [cell.imgView setBackgroundColor:[CommonFunctions navigationBarColor]];
                    break;
                case MenuRows_History:
                    cell.lbDescription.text = @"History";
                    [cell.imgView setImage:[UIImage imageNamed:@"icon_History.png"]];
                    [cell.imgView setBackgroundColor:[CommonFunctions greenColor]];
                    break;
                    
                case MenuRows_Settings:
                    cell.lbDescription.text = @"Settings";
                    [cell.imgView setImage:[UIImage imageNamed:@"icon_Settings.png"]];
                    [cell.imgView setBackgroundColor:[CommonFunctions yellowColor]];
                    break;
                case MenuRows_ChangeUser:
                    cell.lbDescription.text = @"Switch User";
                    [cell.imgView setImage:[UIImage imageNamed:@"icon_SwitchUser.png"]];
                    [cell.imgView setBackgroundColor:[CommonFunctions redColor]];
                default:
                    break;
            }
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 85;
            break;
        case 1:
            return 40;
            break;
        default:
            return 0;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = indexPath;
    if ([CommonFunctions trackingStatus]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Do you want to discard this tracking" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
    else {
        [self setCenterViewController:indexPath];
    }
    
    //[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //TrackingViewController* trackingVC = (TrackingViewController*) self.mm_drawerController.centerViewController;
        //[trackingVC stopTracking];
        [self setCenterViewController:_selectedRow];
    }
    if (buttonIndex ==1) {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (void) setCenterViewController: (NSIndexPath*) indexPath{
    switch (indexPath.section) {
        case 0: {
            UserViewController* userInfoVC = [[UserViewController alloc] initEdit:[CoreDataFuntions curUser]];
            MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:userInfoVC];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            [self.mm_drawerController setRightDrawerViewController:nil];
            break;
        }
        case 1: {
            switch (indexPath.row) {
                    /*case MenuRows_UserInfo:{
                     UserViewController* userInfoVC = [[UserViewController alloc] initEdit:[CoreDataFuntions getCurUser]];
                     MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:userInfoVC];
                     [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
                     [self.mm_drawerController setRightDrawerViewController:nil];
                     break;
                     }*/
                case MenuRows_Activity: {
                    TrackingViewController* trackingVC = [[TrackingViewController alloc] init];
                    MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:trackingVC];
                    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
                    
                    SettingsViewController* settingVC = [[SettingsViewController alloc] initRightDrawer];
                    MyNavigationViewController * rightNavigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:settingVC];
                    [self.mm_drawerController setRightDrawerViewController:rightNavigationController];
                    break;
                }
                case MenuRows_History: {
                    HistoryViewController* historyVC = [[HistoryViewController alloc] init];
                    MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:historyVC];
                    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
                    [self.mm_drawerController setRightDrawerViewController:nil];
                    break;
                }
                case MenuRows_Settings: {
                    SettingsViewController* settingsVC = [[SettingsViewController alloc] initNormal];
                    MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:settingsVC];
                    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
                    [self.mm_drawerController setRightDrawerViewController:nil];
                    break;
                }
                case MenuRows_ChangeUser: {
                    ListUserViewController* listUserVC = [[ListUserViewController alloc] init];
                    MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:listUserVC];
                    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
    
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
