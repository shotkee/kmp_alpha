//
//  UIFont+RMRStyle.h
//  AlfaStrah
//
//  Created by Roman Churkin on 14/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

@import UIKit;

@interface UIFont (RMRStyle)

+ (nonnull UIFont *)rmr_regularFontOfSize:(CGFloat)size;
+ (nonnull UIFont *)rmr_regularLowerCaseFontOfSize:(CGFloat)size;

+ (nonnull UIFont *)rmr_boldFontOfSize:(CGFloat)size;
+ (nonnull UIFont *)rmr_boldLowerCaseFontOfSize:(CGFloat)size;

/// Regular 48
+ (nonnull UIFont *)rmr_A0font;

/// Regular 36
+ (nonnull UIFont *)rmr_A01font;

/// Bold 24
+ (nonnull UIFont *)rmr_A1font;

/// Bold 19
+ (nonnull UIFont *)rmr_A2font;

/// Bold 16
+ (nonnull UIFont *)rmr_A3font;

/// Regular 19
+ (nonnull UIFont *)rmr_A4font;

/// Bold 21
+ (nonnull UIFont *)rmr_A5font;


/// Regular 15
+ (nonnull UIFont *)rmr_B1font;

/// Regular 16
+ (nonnull UIFont *)rmr_B2font;

/// Bold 15
+ (nonnull UIFont *)rmr_B3font;

/// Regular 13
+ (nonnull UIFont *)rmr_B4font;

/// Bold 12
+ (nonnull UIFont *)rmr_B5font;

/// Regular 10
+ (nonnull UIFont *)rmr_B6font;

@end
