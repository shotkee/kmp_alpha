//
//  UIView+RMRHelper.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "UIView+RMRHelper.h"

@implementation UIView (RMRHelper)

+ (instancetype)RMR_loadFromNib {
    Class selfClass = [self class];
    NSString *className = NSStringFromClass(selfClass);
    NSBundle *bundle = [NSBundle bundleForClass:selfClass];
    if (![bundle pathForResource:className ofType:@"nib"]) {
        className = className.pathExtension;
        if (![bundle pathForResource:className ofType:@"nib"]) {
            return nil;
        }
    }

    NSArray *nibContents = [bundle loadNibNamed:className owner:nil options:nil];
    id view = nil;
    for (id obj in nibContents) {
        if ([obj isKindOfClass:selfClass]) {
            view = obj;
            break;
        }
    }
    return view;
}

- (void)addParallaxWithRelativeValue:(CGFloat)relativeValue {
    relativeValue = (CGFloat)fabs(relativeValue);

    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
        type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-relativeValue);
    verticalMotionEffect.maximumRelativeValue = @(relativeValue);

    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
        type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-relativeValue);
    horizontalMotionEffect.maximumRelativeValue = @(relativeValue);

    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[ horizontalMotionEffect, verticalMotionEffect ];

    [self addMotionEffect:group];
}

@end
