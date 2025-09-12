//
//  RMRNavigationControllerDelegate.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 28/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

@import UIKit;

/// Делегат, убирающий заголовки у кнопки назад
@interface RMRNavigationControllerDelegate : NSObject<UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController
    animated:(BOOL)animated;

@end
