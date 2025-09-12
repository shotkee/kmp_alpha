//
//  UIColor+RMRHelper.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 26/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (RMRHelper)

/**
 Инициализирует объект класса UIColor значениями вида 0.f...255.f

 @param red   красный
 @param green зеленый
 @param blue  голубой
 @param alpha прозрачность

 @return объект UIColor
 */
+ (UIColor *)RMR_colorWithRed:(CGFloat)red
                        green:(CGFloat)green
                         blue:(CGFloat)blue
                        alpha:(CGFloat)alpha;

/**
 Создает объект класса UIColor, который на 0.f...1.f процентов темнее

 @param percents значение от 0.f до 1.f

 @return объект UIColor
 */
- (UIColor *)RMR_darkWithPercents:(CGFloat)percents;

/**
 Создает объект класса UIColor, который на 20% процентов темнее

 @return объект UIColor
 */
- (UIColor *)RMR_20PercentsDarker;

/**
 Создает объект класса UIColor, который на 0.f...1.f процентов светлее

 @param percents объект UIColor

 @return объект UIColor
 */
- (UIColor *)RMR_lightWithPercents:(CGFloat)percents;

/**
 Создает объект класса UIColor, который на 20% процентов светлее

 @return объект UIColor
 */
- (UIColor *)RMR_20PercentsLighter;

@end
