//
//  RMRNavigationController.m
//  AlfaStrah
//
//  Created by Roman Churkin on 17/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRNavigationController.h"
#import "RMRNavigationBar.h"

@implementation RMRNavigationController

+ (void)initialize {
    if (self == RMRNavigationController.class) {
        Class selfClass = self.class;
        UINavigationBar<UIAppearance> *appearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ selfClass ]];
        [RMRNavigationBar rmr_configureAppearance:appearance];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)setStrongDelegate:(id<UINavigationControllerDelegate>)strongDelegate {
    _strongDelegate = strongDelegate;
    self.delegate = _strongDelegate;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    // change iOS 13 default modal presentation style behaviour to .fullScreen
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
