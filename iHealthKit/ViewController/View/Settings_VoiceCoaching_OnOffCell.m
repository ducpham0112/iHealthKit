//
//  Settings_VoiceCoaching_OnOffCell.m
//  iHealthKit
//
//  Created by admin on 7/27/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "Settings_VoiceCoaching_OnOffCell.h"

@implementation Settings_VoiceCoaching_OnOffCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont fontWithName:@"American Typewriter" size:14.0];
        
        _voiceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, (self.frame.size.height - 16) / 2, 50, 15)];
        
        self.accessoryView = _voiceSwitch;
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
