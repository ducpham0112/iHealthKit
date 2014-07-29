//
//  DistanceTypeChooserTableViewController.m
//  iHealthKit
//
//  Created by admin on 7/27/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "DistanceTypeChooserTableViewController.h"

@interface DistanceTypeChooserTableViewController ()
@property NSInteger distanceType;
@end

@implementation DistanceTypeChooserTableViewController

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
    } else {
        _distanceType = 0;
    }
    
    [self setTitle:@"Distance Type"];
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
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Metric";
            cell.detailTextLabel.text = @"Kilometers, meters";
            break;
        case 1:
            cell.textLabel.text = @"Imperial";
            cell.detailTextLabel.text = @"Miles, feet";
            break;
        default:
            break;
    }
    
    UIImageView* checkMark = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width - cell.frame.size.height - 10, 3, cell.frame.size.height - 6, cell.frame.size.height - 6)];
   
    if (_distanceType == indexPath.row) {
        [checkMark setImage:[UIImage imageNamed:@"check_icon.png"]];
    }
    else
        [checkMark setImage:[UIImage imageNamed:@"uncheck_icon.png"]];
    [cell addSubview:checkMark];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _distanceType = indexPath.row;
    [[NSUserDefaults standardUserDefaults] setInteger:_distanceType forKey:@"DistanceType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DistanceTypeUpdated" object:self];
    [self.navigationController popViewControllerAnimated:YES];
    
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
