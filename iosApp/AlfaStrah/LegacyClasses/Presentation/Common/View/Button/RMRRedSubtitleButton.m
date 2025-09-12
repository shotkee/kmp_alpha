//
//  RMRRedSubtitleButton.m
//  AlfaStrah
//
//  Created by Roman Churkin on 16/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRRedSubtitleButton.h"

// Helper
#import "UIColor+RMRHelper.h"

// Resources
#import "UIColor+ASColors.h"


@implementation RMRRedSubtitleButton

+ (void)rmr_prepareAppearance:(RMRButton *)button
{
    [super rmr_prepareAppearance:button];

    [button setBackgroundColor:[UIColor rmr_redColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[[UIColor rmr_redColor] RMR_20PercentsDarker] forState:UIControlStateHighlighted];
    [button setBackgroundColor:[UIColor rmr_lightGrayColor] forState:UIControlStateDisabled];
}

- (UIColor *)subtitleColor { return [UIColor rmr_lightPinkColor]; }


@end
