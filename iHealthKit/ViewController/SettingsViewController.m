//
//  SettingsViewController.m
//  iHealthKit
//
//  Created by admin on 7/18/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "SettingsViewController.h"
#import "TrackingViewController.h"
#import "AppDelegate.h"
#import "DistanceTypeChooserTableViewController.h"
#import "Settings_VoiceCoaching_OnOffCell.h"
#import "Setting_DistanceTypeCell.h"
#import "CellWithSegmentControl.h"

typedef enum {
    SettingsVCSection_VoiceCoaching = 0,
    SettingsVCSection_DistanceUnit,
    SettingsVCSection_WeightUnit
    
} SettingsVCSection;

typedef enum {
    RowInUnitSection_distanceType = 0,
    RowInUnitSection_distanceUnit,
    RowInUnitSection_velocityUnit
} RowInUnitSection;

@interface SettingsViewController ()
@property (strong, nonatomic) UITableView *tableView;
@property BOOL voiceCoaching;
@property NSInteger distanceUnit;
@property NSInteger weightUnit;
@property NSInteger veclocityUnit;
@property NSInteger distanceType;
@end


@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveSettings];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceTypeUpdated:) name:@"DistanceTypeUpdated" object:nil];
    
    NSUserDefaults* preference = [NSUserDefaults standardUserDefaults];
    
    if ([NSNumber numberWithInteger:[preference integerForKey:@"DistanceUnit"]] != nil) {
        _distanceUnit = [preference integerForKey:@"DistanceUnit"];
    } else {
        _distanceUnit = 0;
    }
    
    if ([NSNumber numberWithInteger:[preference integerForKey:@"DistanceType"]] != nil) {
        _distanceType = [preference integerForKey:@"DistanceType"];
    } else {
        _distanceType = 0;
    }
    
    if ([NSNumber numberWithInteger:[preference integerForKey:@"VelocityUnit"]] != nil) {
        _veclocityUnit = [preference integerForKey:@"VelocityUnit"];
    } else {
        _veclocityUnit = 0;
    }
    if ([NSNumber numberWithInteger:[preference integerForKey:@"WeightUnit"]] != nil) {
        _weightUnit = [preference integerForKey:@"VelocityUnit"];
    }else {
        _weightUnit = 0;
    }
    if ([NSNumber numberWithBool:[preference boolForKey:@"VoiceCoaching"]] != nil) {
        _voiceCoaching = [preference boolForKey:@"VoiceCoaching"];
    } else {
        _voiceCoaching = NO;
    }
    
    [self setupLeftMenuButton];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunchComplete"]) {
        [self saveSettings];
        UIBarButtonItem* rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(firstTimeSetup)];
        
        [self.navigationItem setRightBarButtonItem:rightBarBtn animated:YES];
    }
    else {
        self.navigationItem.hidesBackButton = YES;
    }
    [self setTitle:@"Settings"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveSettings {
    NSUserDefaults* preference = [NSUserDefaults standardUserDefaults];
    
    [preference setBool:_voiceCoaching forKey:@"VoiceCoaching"];
    [preference setInteger:_distanceUnit forKey:@"DistanceUnit"];
    [preference setInteger:_distanceUnit forKey:@"WeightUnit"];
    [preference setInteger:_veclocityUnit forKey:@"VelocityUnit"];
}

- (void) firstTimeSetup {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLaunchComplete"];
    
    [CommonFunctions setupDrawer];
}

#warning Implement voice coaching
- (void)voiceCoachingChanged: (id) sender {
    UISwitch* voiceCoaching = (UISwitch*) sender;
    _voiceCoaching = voiceCoaching.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:_voiceCoaching forKey:@"VoiceCoaching"];
}

- (void) distanceTypeUpdated: (id) sender {
    _distanceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SettingsVCSection_DistanceUnit] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) distanceTypeSelected{
    DistanceTypeChooserTableViewController* distaceTypeChooserVC = [[DistanceTypeChooserTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:distaceTypeChooserVC animated:YES];
}

- (void) distanceUnitChanged: (id) sender{
    UISegmentedControl* distance = (UISegmentedControl*) sender;
    _distanceUnit = distance.selectedSegmentIndex;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:SettingsVCSection_DistanceUnit]] withRowAnimation:UITableViewRowAnimationFade];
    [[NSUserDefaults standardUserDefaults] setInteger:_distanceUnit forKey:@"DistanceUnit"];
}

- (void)weightUnitChanged:(id)sender {
    UISegmentedControl* weight = (UISegmentedControl*) sender;
    _weightUnit = weight.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:_weightUnit forKey:@"WeightUnit"];
}

- (void)velocityUnitChanged:(id) sender {
    UISegmentedControl* velocity = (UISegmentedControl*) sender;
    _veclocityUnit = velocity.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:_veclocityUnit forKey:@"VelocityUnit"];
}


#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SettingsVCSection_VoiceCoaching: {
            return 1;
            break;
        }
        case SettingsVCSection_DistanceUnit:{
            return 3;
            break;
        }
        case SettingsVCSection_WeightUnit: {
            return 1;
            break;
        }
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.section) {
        case SettingsVCSection_VoiceCoaching: {
            Settings_VoiceCoaching_OnOffCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"VoiceCoachingCell"];
            if (cell == nil) {
                cell = [[Settings_VoiceCoaching_OnOffCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoiceCoachingCell"];
                
                [cell.voiceSwitch addTarget:self action:@selector(voiceCoachingChanged:) forControlEvents:UIControlEventValueChanged];
            }
            
            [cell.textLabel setText:@"Turn on voice"];
            
            BOOL voiceCoaching = ([[NSUserDefaults standardUserDefaults] boolForKey:@"VoiceCoaching"]) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"VoiceCoaching"] : NO;
            [cell.voiceSwitch setOn:voiceCoaching];
            return  cell;
            break;
        }
          
        case SettingsVCSection_WeightUnit: {
            switch (indexPath.row) {
                case 0: {
                    CellWithSegmentControl* cell = [self.tableView dequeueReusableCellWithIdentifier:@"UnitCell"];
                    if (cell == nil) {
                        cell = [[CellWithSegmentControl alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UnitCell"];
                    }
                    
                    cell.textLabel.text = @"Weight";
                    [cell.segmentControl addTarget:self action:@selector(weightUnitChanged:)forControlEvents:UIControlEventValueChanged];
                    [cell.segmentControl setTitle:@"kg" forSegmentAtIndex:0];
                    [cell.segmentControl setTitle:@"lb" forSegmentAtIndex:1];
                    
                    cell.segmentControl.selectedSegmentIndex = _weightUnit;
                    return cell;
                    break;
                }
                default:
                    break;
            }
            break;
        }
            
        case SettingsVCSection_DistanceUnit: {
            switch (indexPath.row) {
                case RowInUnitSection_distanceType: {
                    Setting_DistanceTypeCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"DistanceTypeCell"];
                    if (cell == nil) {
                        cell = [[Setting_DistanceTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DistanceTypeCell"];
                    }
                    cell.textLabel.text = @"Unit System";
                    cell.lbDistanceType.text = (_distanceType == 1) ? @"US/Imperial" : @"Metric";
                    return  cell;
                    break;
                }
                case RowInUnitSection_distanceUnit:
                case RowInUnitSection_velocityUnit:{
                    CellWithSegmentControl* cell = [self.tableView dequeueReusableCellWithIdentifier:@"UnitCell"];
                    if (cell == nil) {
                        cell = [[CellWithSegmentControl alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UnitCell"];
                    }
                    
                    if (indexPath.row == RowInUnitSection_distanceUnit) {
                        cell.textLabel.text = @"Distance";
                        [cell.segmentControl addTarget:self action:@selector(distanceUnitChanged:) forControlEvents:UIControlEventValueChanged];
                        if (_distanceType == 0) {
                            [cell.segmentControl setTitle:@"km" forSegmentAtIndex:0];
                            [cell.segmentControl setTitle:@"m" forSegmentAtIndex:1];
                        }
                        else if (_distanceType == 1) {
                            [cell.segmentControl setTitle:@"mi" forSegmentAtIndex:0];
                            [cell.segmentControl setTitle:@"ft" forSegmentAtIndex:1];
                        }
                        cell.segmentControl.selectedSegmentIndex = _distanceUnit;
                    }
                    else if (indexPath.row == RowInUnitSection_velocityUnit) {
                        cell.textLabel.text = @"Velocity";
                        [cell.segmentControl addTarget:self action:@selector(velocityUnitChanged:) forControlEvents:UIControlEventValueChanged];
                        if (_distanceType == 0) {
                            [cell.segmentControl setTitle:@"km/h" forSegmentAtIndex:0];
                            [cell.segmentControl setTitle:@"m/s" forSegmentAtIndex:1];
                        }
                        else if (_distanceType == 1) {
                            [cell.segmentControl setTitle:@"mph" forSegmentAtIndex:0];
                            [cell.segmentControl setTitle:@"fps" forSegmentAtIndex:1];
                        }
                        cell.segmentControl.selectedSegmentIndex = _veclocityUnit;
                    }
                    
                    return  cell;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* title = @"";
    switch (section) {
        case SettingsVCSection_VoiceCoaching:
            title = @"Voice Coaching";
            break;
        case SettingsVCSection_DistanceUnit:
            title = @"Distance Unit";
            break;
        case SettingsVCSection_WeightUnit:
            title = @"Weight Unit";
        default:
            break;
    }
    return title;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == RowInUnitSection_distanceType && indexPath.section == SettingsVCSection_DistanceUnit) {
        [self distanceTypeSelected];
    }
}

#pragma mark - setup bar button
-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)setupRightMenuButton{
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}




@end
