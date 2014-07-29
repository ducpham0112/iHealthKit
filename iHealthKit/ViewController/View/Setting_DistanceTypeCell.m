//
//  Setting_DistanceTypeCell.m
//  iHealthKit
//
//  Created by admin on 7/27/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "Setting_DistanceTypeCell.h"

@implementation Setting_DistanceTypeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        _lbDistanceType = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 180, (self.frame.size.height - 28) / 2, 145, 28)];
        [_lbDistanceType setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_lbDistanceType];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
