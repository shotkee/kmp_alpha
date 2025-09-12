//
//  UIFont+RMRStyle.m
//  AlfaStrah
//
//  Created by Roman Churkin on 14/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

@import CoreText.SFNTLayoutTypes;
#import "UIFont+RMRStyle.h"

static NSString *const kRMRFontNameRegular = @"KievitPro-Regular";
static NSString *const kRMRFontNameBold = @"KievitPro-Bold";

@implementation UIFont (RMRStyle)

static UIFontDescriptor *_lowerCaseRegularFontDescriptor;
static UIFontDescriptor *_lowerCaseBoldFontDescriptor;
static UIFontDescriptor *_upperCaseRegularFontDescriptor;
static UIFontDescriptor *_upperCaseBoldFontDescriptor;

+ (void)initialize {
    _lowerCaseRegularFontDescriptor = [self buildFontDescriptorWithFontName:kRMRFontNameRegular caseType:kLowerCaseNumbersSelector];
    _lowerCaseBoldFontDescriptor = [self buildFontDescriptorWithFontName:kRMRFontNameBold caseType:kLowerCaseNumbersSelector];
    _upperCaseRegularFontDescriptor = [self buildFontDescriptorWithFontName:kRMRFontNameRegular caseType:kUpperCaseNumbersSelector];
    _upperCaseBoldFontDescriptor = [self buildFontDescriptorWithFontName:kRMRFontNameBold caseType:kUpperCaseNumbersSelector];
}

+ (UIFontDescriptor *)buildFontDescriptorWithFontName:(NSString *)fontName caseType:(NSInteger)caseType {
    NSDictionary *descriptorSettings = @{
        UIFontFeatureTypeIdentifierKey: @(kNumberCaseType),
        UIFontFeatureSelectorIdentifierKey: @(caseType),
    };
    UIFontDescriptor *descriptor = [[UIFontDescriptor alloc] initWithFontAttributes:@{
        UIFontDescriptorNameAttribute: fontName,
        UIFontDescriptorFeatureSettingsAttribute: @[ descriptorSettings ]
    }];
    return descriptor;
}

+ (UIFont *)rmr_regularFontOfSize:(CGFloat)size {
    return [UIFont fontWithDescriptor:_upperCaseRegularFontDescriptor size:size];
}

+ (UIFont *)rmr_regularLowerCaseFontOfSize:(CGFloat)size {
    return [UIFont fontWithDescriptor:_lowerCaseRegularFontDescriptor size:size];
}

+ (UIFont *)rmr_boldFontOfSize:(CGFloat)size {
    return [UIFont fontWithDescriptor:_upperCaseBoldFontDescriptor size:size];
}

+ (UIFont *)rmr_boldLowerCaseFontOfSize:(CGFloat)size {
    return [UIFont fontWithDescriptor:_lowerCaseBoldFontDescriptor size:size];
}

+ (UIFont *)rmr_A0font { return [self rmr_regularFontOfSize:48.f]; }

+ (UIFont *)rmr_A01font { return [self rmr_regularFontOfSize:36.f]; }

+ (UIFont *)rmr_A1font { return [self rmr_boldFontOfSize:24.f]; }

+ (UIFont *)rmr_A2font { return [self rmr_boldFontOfSize:19.f]; }

+ (UIFont *)rmr_A3font { return [self rmr_boldFontOfSize:16.f]; }

+ (UIFont *)rmr_A4font { return [self rmr_regularFontOfSize:19.f]; }

+ (UIFont *)rmr_A5font { return [self rmr_boldFontOfSize:21.f]; }

+ (UIFont *)rmr_B1font { return [self rmr_regularFontOfSize:15.f]; }

+ (UIFont *)rmr_B2font { return [self rmr_regularFontOfSize:16.f]; }

+ (UIFont *)rmr_B3font { return [self rmr_boldFontOfSize:15.f]; }

+ (UIFont *)rmr_B4font { return [self rmr_regularFontOfSize:13.f]; }

+ (UIFont *)rmr_B5font { return [self rmr_boldFontOfSize:12.f]; }

+ (UIFont *)rmr_B6font { return [self rmr_regularFontOfSize:10.f]; }

@end
