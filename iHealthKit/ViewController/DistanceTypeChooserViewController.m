//
//  DistanceTypeChooserTableViewController.m
//  iHealthKit
//
//  Created by admin on 7/27/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "DistanceTypeChooserViewController.h"
//#import "View/CellWithRightImage.h"
#import "View/RightImageCell.h"

@interface DistanceTypeChooserViewController ()
@property NSInteger distanceType;
@end

@implementation DistanceTypeChooserViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    _distanceType = 0;
    if (
        [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey: @"DistanceType"]] != nil) {
         _distanceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceType"];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RightImageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"rightImageCell"];
    
    [self setTitle:@"Unit System"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"rightImageCell";
    RightImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RightImageCell alloc] init];
        //[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    if (indexPath.row == 0) {
        cell.lbUnitType.text = @"Metric";
    } else {
        cell.lbUnitType.text = @"US/Imperial";
    }
    
    if (_distanceType == indexPath.row) {
        [cell.imgCheck setImage:[UIImage imageNamed:@"check_icon.png"]];
    }
    else {
        [cell.imgCheck setImage:[UIImage imageNamed:@"uncheck_icon.png"]];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _distanceType = indexPath.row;
    [[NSUserDefaults standardUserDefaults] setInteger:_distanceType forKey:@"DistanceType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DistanceTypeUpdated" object:self];
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
