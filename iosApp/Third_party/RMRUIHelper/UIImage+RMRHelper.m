//
//  UIImage+RMRHelper.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 26/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "UIImage+RMRHelper.h"

@implementation UIImage (RMRHelper)

+ (UIImage *)RMR_backgroundImageWithColor:(UIColor *)fillColor {
    return [self RMR_backgroundImageWithColor:fillColor size:CGSizeMake(1.f, 1.f)];
}

+ (UIImage *)RMR_backgroundImageWithColor:(UIColor *)fillColor size:(CGSize)size {
    CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)RMR_resizableImageWithBorderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius
    lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor {
    CGFloat borderWidth = lineWidth + cornerRadius;
    CGFloat size = borderWidth * 2.f + 1.f;
    CGRect rect = CGRectMake(0.f, 0.f, size, size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 4.f);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);

    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, lineWidth, lineWidth) cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillPath(context);

    CGFloat insetModifier = lineWidth / 2.f;
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, insetModifier, insetModifier) cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, path);

    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);

    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIEdgeInsets capInsets = UIEdgeInsetsMake(borderWidth, borderWidth, borderWidth, borderWidth);
    return [image resizableImageWithCapInsets:capInsets];
}

@end
