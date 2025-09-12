//
//  RMRButton.m
//  AlfaStrah
//
//  Created by Roman Churkin on 16/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRButton.h"

// Вспомогательные сущности
#import "UIImage+RMRHelper.h"


#pragma mark - Константы

static NSString * const kRMRButtonTypeIncorrectException = @"Button type must be UIButtonTypeCustom";


@implementation RMRButton

+ (void)initialize
{
    [self rmr_prepareAppearance:[self appearance]];
}

+ (void)rmr_prepareAppearance:(RMRButton *)button
{
    // Do nothing
}

- (void)prepareForInterfaceBuilder
{
    [[self class] rmr_prepareAppearance:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (!self) return nil;

    if (self.buttonType != UIButtonTypeCustom) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:kRMRButtonTypeIncorrectException
                                     userInfo:nil];
    }

    return self;
}

+ (id)buttonWithType:(UIButtonType)buttonType
{
    if (buttonType != UIButtonTypeCustom) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:kRMRButtonTypeIncorrectException
                                     userInfo:nil];
    }

    return [super buttonWithType:buttonType];
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    [self setBackgroundImage:[UIImage RMR_backgroundImageWithColor:color]
                    forState:state];
}

@end