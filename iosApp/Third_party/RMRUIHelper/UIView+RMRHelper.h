//
//  UIView+RMRHelper.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (RMRHelper)

/**
 Метод для загрузки view из nib файла.

 @return загруженная view с провешенными properties
 */
+ (instancetype)RMR_loadFromNib;

/**
 Добавляет к view эфект parallax с заданным relativeValue
 */
- (void)addParallaxWithRelativeValue:(CGFloat)relativeValue;

@end
