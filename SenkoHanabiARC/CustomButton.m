//
//  CustomButton.m
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/10.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    NSLog(@"alpha is %lf", alpha);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
