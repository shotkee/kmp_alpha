//
//  RMRNavigationBar.m
//  AlfaStrah
//
//  Created by Roman Churkin on 17/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRNavigationBar.h"

// 3d-party
#import "UIImage+RMRHelper.h"

// Resources
#import "UIColor+ASColors.h"
#import "UIFont+RMRStyle.h"


@implementation RMRNavigationBar

+ (void)initialize
{
    if (self == [RMRNavigationBar class]) [self rmr_configureAppearance:[self appearance]];
}

+ (void)rmr_configureAppearance:(UINavigationBar *)navigationBar
{
    navigationBar.translucent = NO;
    
    navigationBar.shadowImage = [UIImage new];

    navigationBar.tintColor = [UIColor rmr_redColor];
    navigationBar.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;

    navigationBar.backgroundColor = [UIColor rmr_whiteColor];

    [navigationBar setBackgroundImage:[UIImage RMR_backgroundImageWithColor:[UIColor rmr_whiteColor]]
                        forBarMetrics:UIBarMetricsDefault];

    NSDictionary *navBarTitleTextAttributes =
            @{
                    NSFontAttributeName : [UIFont rmr_A2font],
                    NSForegroundColorAttributeName : [UIColor rmr_blackColor]
            };

    navigationBar.titleTextAttributes = navBarTitleTextAttributes;
    
    navigationBar.backIndicatorImage = [UIImage imageNamed:@"ico-nav-back"];
    navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"ico-nav-back-mask"];
}

@end
