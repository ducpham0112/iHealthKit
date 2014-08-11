//
//  Settings_SegmentCell.m
//  iHealthKit
//
//  Created by admin on 8/10/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "Settings_SegmentCell.h"

@implementation Settings_SegmentCell

- (void)awakeFromNib
{
    // Initialization code
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    /*UIFont *font = [UIFont fontWithName:@"Bradley Hand" size:14.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [_segmentControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];*/
}

@end
