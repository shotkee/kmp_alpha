//
//  RMRCircleCodeInputView.m
//  AlfaStrah
//
//  Created by Roman Churkin on 18.03.14.
//  Copyright (c) 2014 RedMadRobot. All rights reserved.
//

#import "RMRCircleCodeInputView.h"
#import "RMRCodeInputCircleView.h"

@interface RMRCircleCodeInputView ()

@property (nonatomic, assign) IBInspectable NSUInteger codeLength;

@end

@implementation RMRCircleCodeInputView

- (void)setCircleDiameter:(CGFloat)circleDiameter {
    _circleDiameter = circleDiameter;
    [self setNeedsLayout];
}

- (void)setCirclePadding:(CGFloat)circlePadding {
    _circlePadding = circlePadding;
    [self setNeedsLayout];
}

#pragma mark - OBCodeInputView

- (void)initialization {
    [super initialization];

    [self configureForCodeLength:self.codeLength];
}

- (void)clear {
    [super clear];

    for (UIView *elementView in self.elementViews) {
        elementView.tintColor = self.emptyColor;
    }
}

- (UIView *)createElementView {
    RMRCodeInputCircleView *roundView = [[RMRCodeInputCircleView alloc] initWithFrame:CGRectZero];
    roundView.translatesAutoresizingMaskIntoConstraints = NO;
    roundView.tintColor = self.emptyColor;
    return roundView;
}

- (void)codeUpdate:(NSString *)newCodeString {
    NSUInteger i = 0;
    NSUInteger codeLength = newCodeString.length;
    for (UIView *elementView in self.elementViews) {
        elementView.tintColor = codeLength > i ? self.filledColor : self.emptyColor;
        i++;
    }
}

- (void)updateConstraints {
    NSMutableDictionary *bindings = NSMutableDictionary.new;
    NSMutableString *format = @"H:|".mutableCopy;
    NSUInteger counter = 0;

    for (UIView *elementView in self.elementViews) {
        elementView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [elementView.widthAnchor constraintEqualToConstant:self.circleDiameter + self.circlePadding],
            [elementView.widthAnchor constraintEqualToConstant:self.circleDiameter + self.circlePadding],
            [elementView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [elementView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];

        NSString *key = [@"view_" stringByAppendingString:@(counter++).stringValue];
        [bindings addEntriesFromDictionary:@{ key: elementView }];
        [format appendFormat:@"[%@]", key];
    }

    [format appendString:@"|"];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:(NSLayoutFormatOptions)0 metrics:nil views:bindings]];

    [super updateConstraints];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];

    [self configureForCodeLength:self.codeLength];
    [self changeCurrentCode:@" "];
}

@end
