//
//  RMRRoundView.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 09/02/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "RMRRoundView.h"


@implementation RMRRoundView

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    CGFloat radius = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) / 2.f;
    self.layer.cornerRadius = radius;
}

@end
