//
//  UIImage+RMRHelper.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 26/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RMRHelper)

/**
 Метод создает изображение размером 1х1 с заданным цветом заливки

 @param fillColor цвет заливки
 */
+ (UIImage *)RMR_backgroundImageWithColor:(UIColor *)fillColor;

/**
 Метод создает изображение заданного размера с указанным цветом заливки

 @param fillColor цвет заливки
 @param size  размер
 */
+ (UIImage *)RMR_backgroundImageWithColor:(UIColor *)fillColor size:(CGSize)size;

/**
 Метод создает изображение прямоугольника переменного размера с указанным радиусом скругления

 @param borderColor  цвет контура
 @param cornerRadius радиус скругления
 @param lineWidth    толщина контура
 @param fillColor    цвет заливки
 */
+ (UIImage *)RMR_resizableImageWithBorderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius
    lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor;

@end
