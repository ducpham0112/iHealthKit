//
//  LeftMenuTableViewCell.m
//  iHealthKit
//
//  Created by admin on 7/26/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell

- (void)awakeFromNib
{
    // Initialization code
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.imgView.layer.cornerRadius = self.imgView.frame.size.width/2;
    self.imgView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

@end
