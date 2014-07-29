//
//  UserInfo_TextFieldCell.m
//  iHealthKit
//
//  Created by admin on 7/27/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "CellWithTextField.h"

@implementation CellWithTextField

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.textLabel setTextColor:[CommonFunctions grayColor]];
        [self.textLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 0, self.frame.size.width - 120, self.frame.size.height)];
        [_textField setTintColor:[CommonFunctions grayColor]];
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [CommonFunctions lightGrayColor]}];
         [self addSubview:_textField];
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
