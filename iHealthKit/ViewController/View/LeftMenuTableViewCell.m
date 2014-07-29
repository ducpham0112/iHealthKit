//
//  LeftMenuTableViewCell.m
//  iHealthKit
//
//  Created by admin on 7/26/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "LeftMenuTableViewCell.h"

@implementation LeftMenuTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self setBackgroundColor:[CommonFunctions leftMenuBackgroundColor]];
    [self.lbDescription setTextColor:[UIColor whiteColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
