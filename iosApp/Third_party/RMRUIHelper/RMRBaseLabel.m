//
//  RMRBaseLabel.m
//  AlfaStrah
//
//  Created by Roman Churkin on 15/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRBaseLabel.h"


@interface UILabel (APPEARANCE)
- (void)rmr_setFont:(UIFont *)font UI_APPEARANCE_SELECTOR;
@end
@implementation UILabel (APPEARANCE)
- (void)rmr_setFont:(UIFont *)font { self.font = font; }
@end


@implementation RMRBaseLabel

+ (void)initialize
{
    [self rmr_prepareAppearence:[self appearance]];
}

+ (void)rmr_prepareAppearence:(UILabel *)label
{
    [label rmr_setFont:[self rmr_font]];
}

- (void)prepareForInterfaceBuilder
{
    [[self class] rmr_prepareAppearence:self];
}

+ (UIFont *)rmr_font
{
    return [UIFont systemFontOfSize:[UIFont systemFontSize]];
}

@end
