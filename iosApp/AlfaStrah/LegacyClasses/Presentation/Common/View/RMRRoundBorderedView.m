//
//  RMRRoundBorderedView.m
//  AlfaStrah
//
//  Created by Roman Churkin on 13/05/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRRoundBorderedView.h"


@implementation RMRRoundBorderedView

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;

    self.layer.borderColor = borderColor.CGColor;
}

- (void)initialize
{
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = self.borderColor.CGColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self initialize];

    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) return nil;

    [self initialize];

    return self;
}

@end
