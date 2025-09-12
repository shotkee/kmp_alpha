//
//  RMRImageView.m
//  AlfaStrah
//
//  Created by Roman Churkin on 17/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRImageView.h"


@implementation RMRImageView

- (void)initialize
{
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIColor *tintColor = self.tintColor;
    self.tintColor = nil;
    self.tintColor = tintColor;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self initialize];
}

- (void)prepareForInterfaceBuilder
{
    [self initialize];
}

@end
