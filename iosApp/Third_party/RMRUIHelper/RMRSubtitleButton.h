//
//  RMRSubtitleButton.h
//  AlfaStrah
//
//  Created by Roman Churkin on 16/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRButton.h"

@interface RMRSubtitleButton : RMRButton

@property (nonatomic, copy) IBInspectable NSString *title;
@property (nonatomic, copy) IBInspectable NSString *subtitle;


+ (void)rmr_prepareAppearance:(RMRButton *)button NS_REQUIRES_SUPER;

- (UIFont *)titleFont;

- (UIFont *)titleSelectedFont;

- (UIColor *)titleColor;

- (UIFont *)subtitleFont;

- (UIColor *)subtitleColor;

@end
