//
//  LeftMenuHeaderCell.m
//  iHealthKit
//
//  Created by admin on 8/9/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "LeftMenuHeaderCell.h"

@implementation LeftMenuHeaderCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width/2;
    self.imgAvatar.clipsToBounds = YES;
}

@end
