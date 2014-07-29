//
//  LeftMenuTableViewController.m
//  iHealthKit
//
//  Created by admin on 7/18/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "LeftMenuTableViewController.h"
#import "View/MMSideDrawerTableViewCell.h"
#import "HistoryTableViewController.h"
#import "TrackingViewController.h"
#import "SettingsViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "ListUserTableViewController.h"
#import "UserViewController.h"
#import "MyNavigationViewController.h"
#import "View/LeftMenuTableViewCell.h"

typedef enum {
    MenuRows_UserInfo = 0,
    MenuRows_Activity,
    MenuRows_History,
    MenuRows_Settings,
    MenuRows_ChangeUser

}MenuRows;

@interface LeftMenuTableViewController ()

@property NSIndexPath* selectedRow;

@end

@implementation LeftMenuTableViewController

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftMenuTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"leftMenuCell"];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.view setBackgroundColor:[CommonFunctions leftMenuBackgroundColor]];
    
    MyUser* curUser = [CoreDataFuntions getCurUser];
    [self setTitle:[CoreDataFuntions getFullnameUser:curUser]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"leftMenuCell";
    
     LeftMenuTableViewCell* cell = (LeftMenuTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[LeftMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    switch (indexPath.row) {
        case MenuRows_UserInfo:
            cell.lbDescription.text = @"User Information";
            [cell.imgView setImage:[UIImage imageNamed:@"icon_UserInfo.png"]];
            break;
        case MenuRows_Activity:
            cell.lbDescription.text = @"Activity";
            [cell.imgView setImage:[UIImage imageNamed:@"icon_Activity.png"]];
            break;
        case MenuRows_History:
            cell.lbDescription.text = @"History";
            [cell.imgView setImage:[UIImage imageNamed:@"icon_History.png"]];
            break;
            
        case MenuRows_Settings:
            cell.lbDescription.text = @"Settings";
            [cell.imgView setImage:[UIImage imageNamed:@"icon_Settings.png"]];
            break;
        case MenuRows_ChangeUser:
            cell.lbDescription.text = @"Switch User";
            [cell.imgView setImage:[UIImage imageNamed:@"icon_SwitchUser.png"]];
        default:
            break;
        }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = indexPath;
    if ([CommonFunctions getTrackingStatus]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Do you want to discard this tracking" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
    else {
        [self setCenterViewController:indexPath];
    }
    
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
    switch (indexPath.row) {
        case MenuRows_UserInfo:{
            UserViewController* userInfoVC = [[UserViewController alloc] initEdit:[CoreDataFuntions getCurUser]];
            MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:userInfoVC];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            [self.mm_drawerController setRightDrawerViewController:nil];
            break;
        }
        case MenuRows_Activity: {
            TrackingViewController* trackingVC = [[TrackingViewController alloc] init];
            MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:trackingVC];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            
            SettingsViewController* settingVC = [[SettingsViewController alloc] init];
            MyNavigationViewController * rightNavigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:settingVC];
            [self.mm_drawerController setRightDrawerViewController:rightNavigationController];
            break;
        }
        case MenuRows_History: {
            HistoryTableViewController* historyVC = [[HistoryTableViewController alloc] init];
            MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:historyVC];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            [self.mm_drawerController setRightDrawerViewController:nil];
            break;
        }
        case MenuRows_Settings: {
            SettingsViewController* settingsVC = [[SettingsViewController alloc] init];
            MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:settingsVC];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            [self.mm_drawerController setRightDrawerViewController:nil];
            break;
        }
        case MenuRows_ChangeUser: {
            ListUserTableViewController* listUserVC = [[ListUserTableViewController alloc] init];
            MyNavigationViewController * navigationController = [[MyNavigationViewController alloc] initWithBarColor:[CommonFunctions navigationBarColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleLightContent rootViewController:listUserVC];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            break;
        }
        default:
            break;
    }
    
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
