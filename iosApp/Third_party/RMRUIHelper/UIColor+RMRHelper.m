//
//  UIColor+RMRHelper.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 26/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "UIColor+RMRHelper.h"


@implementation UIColor (RMRHelper)

+ (UIColor *)RMR_colorWithRed:(CGFloat)red
                        green:(CGFloat)green
                         blue:(CGFloat)blue
                        alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red/255.f
                           green:green/255.f
                            blue:blue/255.f
                           alpha:alpha];
}

- (UIColor *)RMR_colorWithMultiplier:(CGFloat)multiplier
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;

    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        red   = red? red * multiplier: multiplier -1.f;
        green = green? green * multiplier: multiplier -1.f;
        blue  = blue? blue * multiplier: multiplier -1.f;

        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Не удалось получить компоненты цвета"
                                     userInfo:nil];
    }
}

- (UIColor *)RMR_darkWithPercents:(CGFloat)percents
{
    percents = 1.f - percents;

    return [self RMR_colorWithMultiplier:percents];
}

- (UIColor *)RMR_20PercentsDarker { return [self RMR_darkWithPercents:.2f]; }

- (UIColor *)RMR_lightWithPercents:(CGFloat)percents
{
    percents = 1.f + percents;

    return [self RMR_colorWithMultiplier:percents];
}

- (UIColor *)RMR_20PercentsLighter { return [self RMR_lightWithPercents:.2f]; }

@end
