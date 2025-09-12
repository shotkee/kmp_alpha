//
//  RMRAlphaSubtitleButton.m
//  AlfaStrah
//
//  Created by Olga Vorona on 21/01/16.
//  Copyright © 2016 RedMadRobot. All rights reserved.
//

#import "RMRAlphaSubtitleButton.h"
#import "UIFont+RMRStyle.h"

@implementation RMRAlphaSubtitleButton

- (UIFont *)titleFont  { return [UIFont rmr_A4font]; }
- (UIFont *)titleSelectedFont  { return [UIFont rmr_A2font]; }
- (UIColor *)titleColor { return [UIColor whiteColor]; }

- (UIFont *)subtitleFont { return [UIFont rmr_B1font]; }
- (UIColor *)subtitleColor { return [[UIColor whiteColor] colorWithAlphaComponent:.94f]; }
- (UIColor *)subtitleDisabledColor { return [UIColor whiteColor]; }

@end
