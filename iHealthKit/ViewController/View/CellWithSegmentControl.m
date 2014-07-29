//
//  Setting_UnitCell.m
//  iHealthKit
//
//  Created by admin on 7/27/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "CellWithSegmentControl.h"

@implementation CellWithSegmentControl

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"", nil]];
        _segmentControl.frame = CGRectMake(self.frame.size.width - 115, (self.frame.size.height - 28) / 2, 115, 28);
        [self setAccessoryView:_segmentControl];
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
