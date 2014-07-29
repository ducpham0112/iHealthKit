//
//  CellWithRightImage.m
//  iHealthKit
//
//  Created by admin on 7/29/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "CellWithRightImage.h"

@implementation CellWithRightImage

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height - 10, 3, self.frame.size.height - 6, self.frame.size.height - 6)];
        [self addSubview:_rightImage];
        
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
