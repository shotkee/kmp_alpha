//
//  RMRNoBarNavigationControllerDelegate.m
//  AlfaStrah
//
//  Created by Roman Churkin on 17/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRNoBarNavigationControllerDelegate.h"
#import "RMRNavBarViewControllerDelegate.h"

@implementation RMRNoBarNavigationControllerDelegate {
    BOOL _shouldNotHideNavBar;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController
    animated:(BOOL)animated {
    [super navigationController:navigationController willShowViewController:viewController animated:animated];

    BOOL hideNavigationBar;
    if ([viewController conformsToProtocol:@protocol(RMRNavBarViewControllerDelegate)]) {
        hideNavigationBar = !((id<RMRNavBarViewControllerDelegate>)viewController).showNavigationBar;
    } else {
        hideNavigationBar = [navigationController.viewControllers indexOfObject:viewController] == 0;
        //_shouldNotHideNavBar перекрывает вычисляемое значение hideNavigationBar
        if (hideNavigationBar && _shouldNotHideNavBar) {
            hideNavigationBar = NO;
        }
    }

    [navigationController setNavigationBarHidden:hideNavigationBar animated:YES];

    _shouldNotHideNavBar = NO;
}

- (void)setShouldNotHideNavBar {
    _shouldNotHideNavBar = YES;
}

@end
