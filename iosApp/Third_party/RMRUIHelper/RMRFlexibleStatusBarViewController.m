//
//  RMRFlexibleStatusBarViewController.m
//  RMRUIHelper
//
//  Created by Igor Bulyga on 11/12/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "RMRFlexibleStatusBarViewController.h"


@implementation RMRFlexibleStatusBarViewController

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

@end