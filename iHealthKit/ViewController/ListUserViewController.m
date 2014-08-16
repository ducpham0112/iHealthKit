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

@property (nonatomic, strong) NSMutableArray* listUser;

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

- (void) viewDidAppear:(BOOL)animated {
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:@"List Other Users"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ListUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell"];
    
    [self loadData];
    
    [self setupBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listUserChanged) name:@"ListUserChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listUserChanged) name:@"UserChanged" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadData {
    _listUser = [NSMutableArray arrayWithArray:[CoreDataFuntions listUser]];
    for (MyUser* user in _listUser) {
        if ([user.isCurrentUser boolValue]) {
            [_listUser removeObject:user];
            return;
        }
    }
}

- (void) addUser {
    UserViewController* addUserVC = [[UserViewController alloc] initAdd];
    [self.navigationController pushViewController:addUserVC animated:YES];
}

- (void) listUserChanged {
    [self loadData];
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
    userCell.lbName.text = [CoreDataFuntions fullName:user];
    
    userCell.lbBirthDay.text = [NSDateFormatter localizedStringFromDate:user.birthday dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    userCell.lbActivity.text = [NSString stringWithFormat:@"Activities: %d",[[user.routeHistory allObjects] count]];
    
    /*if (user.avatar != nil) {
        userCell.imgAvatar.image = [[UIImage alloc] initWithData:user.avatar];
    } else {
        if ([user.isMale integerValue] == 0) {
            userCell.imgAvatar.image = [UIImage imageNamed:@"avatar_male.jpg"];
        } else {
            userCell.imgAvatar.image = [UIImage imageNamed:@"avatar_female.jpg"];
        }
    }*/
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        UIImage* avatar;
        if (user.avatar) {
            avatar = [[UIImage alloc] initWithData:user.avatar];
        }
        else {
            if ([user.isMale integerValue] == 0) {
                avatar = [UIImage imageNamed:@"avatar_male.jpg"];
            }
            else {
                avatar = [UIImage imageNamed:@"avatar_female.jpg"];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            userCell.imgAvatar.image = avatar;
            [cell setNeedsLayout];
        });
    });
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserViewController* userInforVC = [[UserViewController alloc] initLogIn:[_listUser objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:userInforVC animated:YES];
}
@end
