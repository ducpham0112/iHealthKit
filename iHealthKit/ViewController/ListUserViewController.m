//
//  ListUserTableViewController.m
//  iHealthKit
//
//  Created by admin on 7/21/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "ListUserViewController.h"
#import "View/ListUserCell.h"
#import "UserViewController.h"

@interface ListUserViewController ()

@property (nonatomic, strong) NSArray* listUser;

@end

@implementation ListUserViewController

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
    [self setTitle:@"List Users"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ListUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell"];
    _listUser = [CoreDataFuntions getListUser];
    
    
    [self setupBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listUserChanged) name:@"ListUserChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listUserChanged) name:@"UserInfoChanged" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) addUser {
    UserViewController* addUserVC = [[UserViewController alloc] initAdd];
    [self.navigationController pushViewController:addUserVC animated:YES];
}

- (void) listUserChanged {
    _listUser = [CoreDataFuntions getListUser];
    [self.tableView reloadData];
}


#pragma mark - setup bar button
-(void)setupBarButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    UIBarButtonItem* rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUser)];
    [self.navigationItem setRightBarButtonItem:rightBarBtn];
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
    return [_listUser count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    ListUserCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell: (UITableViewCell*) cell atIndexPath: (NSIndexPath*) indexPath {
    ListUserCell* userCell = (ListUserCell*) cell;
    MyUser* user = [_listUser objectAtIndex:indexPath.row];
    userCell.lbName.text = [CoreDataFuntions getFullnameUser:user];
    
    userCell.lbBirthDay.text = [NSDateFormatter localizedStringFromDate:user.birthday dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    userCell.lbActivity.text = [NSString stringWithFormat:@"Activities: %d",[[user.routeHistory allObjects] count]];
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserViewController* userInforVC = [[UserViewController alloc] initLogIn:[_listUser objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:userInforVC animated:YES];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.

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
