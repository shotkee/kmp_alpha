//
//  RMRModalView.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 28/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@protocol RMRModalView <NSObject>

@required

- (void)prepareForAnimation;

- (void)animationAppear;
- (void)animationHide;

- (void)configureLayoutForContainer:(UIView *)container;


@optional

- (void)customShowAnimation:(void(^)(void))animations;

- (void)customHideAnimation:(void(^)(void))animations
                 completion:(void (^)(BOOL finished))completion;

@end
