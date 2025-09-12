//
//  RMRDigitCodeInputView.m
//  AlfaStrah
//
//  Created by Roman Churkin on 12.05.14.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRDigitCodeInputView.h"

// Ресурсы
#import "UIColor+ASColors.h"
#import "UIFont+RMRStyle.h"


#pragma mark - Вспомогательные функции

NSString *getCharacterAtPosition(NSString *string, NSUInteger pos)
{
    if ([string length] > pos) return [string substringWithRange:NSMakeRange(pos, 1)];
    else return @"";
}


@interface RMRDigitCodeInputView ()

#pragma mark — Свойства

@property (nonatomic, assign) IBInspectable NSUInteger codeLength;

@end


@implementation RMRDigitCodeInputView

#pragma mark - Properties

- (void)setFont:(UIFont *)font
{
    _font = font;
    for (UITextField *digitTextField in self.elementViews) {
        digitTextField.font = font;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    for (UITextField *digitTextField in self.elementViews) {
        digitTextField.textColor = textColor;
    }
}

    
#pragma mark - OBCodeInputView

- (void)initialization
{
    [super initialization];
    
    // Default Font
    self.font = [UIFont rmr_A0font];

    // Default TextColor
    self.textColor = [UIColor rmr_redColor];

    [self configureForCodeLength:self.codeLength];
}

- (void)clear
{
    [super clear];

    [self codeUpdate:nil];
}

- (UIView *)createElementView
{
    UITextField *digitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    digitTextField.translatesAutoresizingMaskIntoConstraints = NO;
    digitTextField.userInteractionEnabled = NO;
//    digitTextField.text            = kOBCodeViewEmptyCharacter;
    digitTextField.textAlignment   = NSTextAlignmentCenter;
    digitTextField.borderStyle     = UITextBorderStyleNone;
    digitTextField.opaque          = NO;
    digitTextField.backgroundColor = [UIColor rmr_lightGrayColor];
    digitTextField.font            = self.font;
    digitTextField.textColor       = self.textColor;
    digitTextField.layer.cornerRadius = 2.f;
    if (@available(iOS 12.0, *)) {
        digitTextField.textContentType = UITextContentTypeOneTimeCode;
    }
    return digitTextField;
}

- (void)codeUpdate:(NSString *)newCodeString
{
    NSUInteger i = 0;
    NSString *code = newCodeString;
    for (UITextField *digitTextField in self.elementViews) {
        digitTextField.text = getCharacterAtPosition(code, i);
        i++;
    }
}

- (void)updateConstraints
{
    NSMutableDictionary *bindings = [NSMutableDictionary dictionary];
    NSMutableString *format = [@"H:|" mutableCopy];
    NSUInteger counter = 0;

    for (UIView *elementView in self.elementViews) {
        elementView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [elementView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [elementView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];

        NSString *key = [@"view_" stringByAppendingString:[@(counter++) stringValue]];

        [bindings addEntriesFromDictionary:@{key : elementView}];

        [format appendFormat:@"-(4)-[%@(40)]", key];
    }

    [format appendString:@"-(4)-|"];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:(NSLayoutFormatOptions)0
                                                                 metrics:nil
                                                                   views:bindings]];

    [super updateConstraints];
}

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];

    [self configureForCodeLength:self.codeLength];

    [self changeCurrentCode:@"530"];
}

@end
