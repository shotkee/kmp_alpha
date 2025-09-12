//
//  RMRButton.h
//  AlfaStrah
//
//  Created by Roman Churkin on 16/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface RMRButton : UIButton

+ (void)initialize NS_REQUIRES_SUPER;

- (void)prepareForInterfaceBuilder NS_REQUIRES_SUPER;

+ (instancetype)buttonWithType:(UIButtonType)buttonType NS_REQUIRES_SUPER;

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;


#pragma mark — Методы реализации в сабклассах

+ (void)rmr_prepareAppearance:(RMRButton *)button;


#pragma mark — Недоступные инициализаторы

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
