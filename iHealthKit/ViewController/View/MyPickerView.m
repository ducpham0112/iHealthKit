//
//  MyPickerView.m
//  iHealthKit
//
//  Created by admin on 7/24/14.
//  Copyright (c) 2014 Duc Pham. All rights reserved.
//

#import "MyPickerView.h"

@implementation MyPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)numberOfComponents {
    return ([_pickerData count] == 0) ? 1 : [_pickerData count];
}

@end
