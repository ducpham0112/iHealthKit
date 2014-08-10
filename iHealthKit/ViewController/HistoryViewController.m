//
//  HistoryViewController.m
//  iHealthKit
//
//  Created by admin on 8/6/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "HistoryViewController.h"
#import "View/HistoryCell.h"
#import "RouteViewController.h"

#define PAGE_NUMBER 4

@interface HistoryViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)pageChanged:(id)sender;

@property (nonatomic, strong) NSArray* listRoute;

@property float totalDistance;
@property NSTimeInterval totalTime;
@property float totalCalories;
@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"History"];
    [self setupBarButton];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"historyCell"];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    
    [self loadData];
    
    _scrollView.delegate = self;
    [self GeneratePages];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = PAGE_NUMBER;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyChanged) name:@"HistoryChanged" object:nil];
    
    
}

#pragma mark - load history data
- (void) loadData {
    _listRoute = [[[CoreDataFuntions getCurUser] routeHistory] allObjects];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO];
    _listRoute = [_listRoute sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    _totalCalories = 0.0;
    _totalDistance = 0.0;
    _totalTime = 0.0;
    
    for (MyRoute* route in _listRoute) {
        _totalTime += [CommonFunctions getDuration:route.startTime endTime:route.endTime];
        _totalDistance += [route.distance floatValue];
        _totalCalories += [route.calories floatValue];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - notification handler
- (void) historyChanged {
    [self loadData];
    [self.tableView reloadData];
}

#pragma mark - setup bar button
-(void)setupBarButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listRoute.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"historyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[HistoryCell alloc] init];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell: (UITableViewCell*) cell atIndexPath: (NSIndexPath*) indexPath {
    HistoryCell* routeCell = (HistoryCell*) cell;
    MyRoute* route = [_listRoute objectAtIndex:indexPath.row];
    
    routeCell.lbDateTime.text = [NSDateFormatter localizedStringFromDate:route.startTime dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    
    routeCell.lbAvgSpeedDescription.text = [NSString stringWithFormat:@"Avg.Speed (%@)", [CommonFunctions getVelocityUnitString]];
    routeCell.lbAvgSpeedValue.text = [NSString stringWithFormat:@"%.2f", [route.avgSpeed floatValue]];
    
    routeCell.lbDistanceDescription.text = [NSString stringWithFormat:@"Distance (%@)", [CommonFunctions getDistanceUnitString]];
    routeCell.lbDistanceValue.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertDistance:[route.distance floatValue]]];
    
    //routeCell.lbDurationDescription.text = @"Duration";
    routeCell.lbDurationValue.text = [CommonFunctions stringSecondFromInterval:[CommonFunctions getDuration:route.startTime endTime:route.endTime]];
    
    int hour = [CommonFunctions datePart:route.startTime withPart:DatePartType_hour];
    if (hour > 6 && hour < 18) {
        routeCell.imgDayNight.image = [UIImage imageNamed:@"icon_sun.png"];
    } else {
        routeCell.imgDayNight.image = [UIImage imageNamed:@"icon_moon.png"];
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

#pragma mark - table view delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RouteViewController* routeVC = [[RouteViewController alloc] initwithRoute:[_listRoute objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:routeVC animated:YES];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  NO;
}

#pragma mark - scrollview delegate
- (void) GeneratePages {
    CGSize scrollViewSize = CGSizeMake(_scrollView.frame.size.width * PAGE_NUMBER, _scrollView.frame.size.height);
    [_scrollView setContentSize:scrollViewSize];
    for (int i = 0; i < PAGE_NUMBER; i++) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0.0f;
        UIView* page = [[UIView alloc] initWithFrame:frame];
        //page.backgroundColor = [UIColor grayColor];
        UILabel* lbValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, 320, 70)];
        lbValue.backgroundColor = [UIColor clearColor];
        lbValue.textColor = [CommonFunctions navigationBarColor];
        lbValue.textAlignment = NSTextAlignmentCenter;
        lbValue.font = [UIFont fontWithName:@"Geeza Pro" size:70.0f];
        [page addSubview:lbValue];
        
        UILabel* lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 320, 21)];
        lbDescription.backgroundColor = [UIColor clearColor];
        lbDescription.textColor = [CommonFunctions grayColor];
        lbDescription.font = [UIFont fontWithName:@"Bradley Hand" size:19.0];
        lbDescription.textAlignment = NSTextAlignmentCenter;
        [page addSubview:lbDescription];
        
        switch (i) {
            case 1: {
                lbDescription.text = [NSString stringWithFormat:@"Total Distance (%@)", [CommonFunctions getDistanceUnitString]];
                lbValue.text = [NSString stringWithFormat:@"%.2f", [CommonFunctions convertDistance:_totalDistance]];
                break;
            }
            case 2: {
                lbDescription.text = @"Total Duration";
                lbValue.text = [CommonFunctions stringSecondFromInterval:_totalTime];
                break;
            }
            case 3: {
                lbDescription.text = @"Total Calories";
                lbValue.text = [NSString stringWithFormat:@"%.2f", _totalCalories];
               break;
            }
            case 0: {
                lbDescription.text = @"Total Avtivities";
                lbValue.text = [NSString stringWithFormat:@"%d", [_listRoute count]];
            }
            default:
                break;
        }
        
        [_scrollView addSubview:page];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat viewWidth = scrollView.frame.size.width;
    
    int pageNumber = floor((scrollView.contentOffset.x - viewWidth/50) / viewWidth) + 1;
    self.pageControl.currentPage = pageNumber;
}

- (IBAction)pageChanged:(id)sender {
    int pageNumber = self.pageControl.currentPage;
    
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width*pageNumber;
    frame.origin.y = 0;
    
    [_scrollView scrollRectToVisible:frame animated:YES];
}
@end



































