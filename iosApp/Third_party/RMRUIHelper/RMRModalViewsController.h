//
//  RMRModalViewsController.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 28/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

@import UIKit;

#import "RMRModalView.h"


@interface RMRModalViewsController : NSObject

+ (instancetype)sharedController;

- (void)presentView:(UIView<RMRModalView> *)modalView;

- (void)dismissView:(UIView *)modalView completion:(void(^)(void))completion;

- (UIView *)viewOnScreen;

@end
