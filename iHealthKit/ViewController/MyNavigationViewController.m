//
//  MyNavigationViewController.m
//  iHealthKit
//
//  Created by admin on 7/25/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "MyNavigationViewController.h"


@interface MyNavigationViewController ()
@property UIStatusBarStyle statusBarStyle;
@end

@implementation MyNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id) initWithBarColor: (UIColor*) color textColor:(UIColor*) textColor statusBarStyle: (UIStatusBarStyle) statusBarStyle rootViewController:(UIViewController*) rootViewController{
    MyNavigationViewController* myNav = [[MyNavigationViewController alloc] initWithRootViewController:rootViewController];
    [myNav.navigationBar setBarTintColor:color];
    NSDictionary *navBarTitleDict;
    UIColor * titleColor = textColor;
    navBarTitleDict = @{NSForegroundColorAttributeName:titleColor};
    [myNav.navigationBar setTitleTextAttributes:navBarTitleDict];
    //myNav.navigationBar.translucent = NO;
    myNav.statusBarStyle = statusBarStyle;
    return myNav;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return _statusBarStyle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
