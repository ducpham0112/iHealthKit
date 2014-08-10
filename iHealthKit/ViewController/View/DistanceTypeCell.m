//
//  DistanceTypeCell.m
//  iHealthKit
//
//  Created by admin on 8/7/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "DistanceTypeCell.h"

@implementation DistanceTypeCell

- (void)awakeFromNib
{
    // Initialization code
    self.textLabel.font = [UIFont fontWithName:@"American Typewriter" size:14.0];
    self.textLabel.text = @"Unit System";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
