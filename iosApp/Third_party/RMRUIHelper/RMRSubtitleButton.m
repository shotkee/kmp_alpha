//
//  RMRSubtitleButton.m
//  AlfaStrah
//
//  Created by Roman Churkin on 16/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRSubtitleButton.h"


#pragma mark - Константы

static const UIEdgeInsets kButtonContentEdgeInsetsSmall = {16.f, 10.f, 16.f, 10.f};
static const UIEdgeInsets kButtonContentEdgeInsetsBig   = {20.f, 10.f, 20.f, 10.f};


@implementation RMRSubtitleButton

- (void)initialize
{
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

+ (id)buttonWithType:(UIButtonType)buttonType
{
    RMRSubtitleButton *button = [super buttonWithType:buttonType];

    [button initialize];

    return button;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

+ (void)rmr_prepareAppearance:(RMRButton *)button
{
    button.contentEdgeInsets = kButtonContentEdgeInsetsSmall;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self updateTitle];
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    [self updateTitle];
}

- (void)updateTitle
{
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *titleStringSelected = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *titleStringDisabled = [[NSMutableAttributedString alloc] init];

    if (self.title.length) {
        NSDictionary *titleAttributes = @{
                NSFontAttributeName : [self titleFont],
                NSForegroundColorAttributeName : [self titleColor]
        };

        NSDictionary *titleSelectedAttributes = @{
                NSFontAttributeName : [self titleSelectedFont],
                NSForegroundColorAttributeName : [self titleColor]
        };

        NSDictionary *titleDisabledAttributes = @{
                NSFontAttributeName : [self titleFont],
                NSForegroundColorAttributeName : [self titleColor]
        };

        [titleString appendAttributedString:
            [[NSMutableAttributedString alloc] initWithString:self.title
                                                   attributes:titleAttributes]];

        [titleStringSelected appendAttributedString:
            [[NSMutableAttributedString alloc] initWithString:self.title
                                                   attributes:titleSelectedAttributes]];

        [titleStringDisabled appendAttributedString:
            [[NSAttributedString alloc] initWithString:self.title
                                            attributes:titleDisabledAttributes]];
    }

    if (self.subtitle.length) {
        if (titleString.length) {
            [titleString appendAttributedString:
                    [[NSMutableAttributedString alloc] initWithString:@"\n"
                                                           attributes:nil]];
            [titleStringSelected appendAttributedString:
                [[NSMutableAttributedString alloc] initWithString:@"\n"
                                                       attributes:nil]];
            [titleStringDisabled appendAttributedString:
                [[NSMutableAttributedString alloc] initWithString:@"\n"
                                                       attributes:nil]];
        }

        self.contentEdgeInsets = kButtonContentEdgeInsetsSmall;

        NSDictionary *subtitleAttributes = @{
                NSFontAttributeName : [self subtitleFont],
                NSForegroundColorAttributeName : [self subtitleColor]
        };

        NSDictionary *subtitleDisabledAttributes = @{
                NSFontAttributeName : [self subtitleFont],
                NSForegroundColorAttributeName : [self subtitleDisabledColor]
        };

        [titleString appendAttributedString:
            [[NSMutableAttributedString alloc] initWithString:self.subtitle
                                                   attributes:subtitleAttributes]];
        [titleStringSelected appendAttributedString:
            [[NSMutableAttributedString alloc] initWithString:self.subtitle
                                                   attributes:subtitleAttributes]];
        [titleStringDisabled appendAttributedString:
            [[NSAttributedString alloc] initWithString:self.subtitle
                                            attributes:subtitleDisabledAttributes]];
    } else self.contentEdgeInsets = kButtonContentEdgeInsetsBig;

    [self setAttributedTitle:titleString forState:UIControlStateNormal];
    [self setAttributedTitle:titleStringSelected forState:UIControlStateSelected];
    [self setAttributedTitle:titleStringDisabled forState:UIControlStateDisabled];
}

- (UIFont *)titleFont
{
    return [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
}

- (UIFont *)titleSelectedFont
{
    return [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
}

- (UIColor *)titleColor
{
    return [UIColor blackColor];
}

- (UIFont *)subtitleFont
{
    return [UIFont systemFontOfSize:[UIFont buttonFontSize]];
}

- (UIColor *)subtitleColor
{
    return [UIColor grayColor];
}

- (UIColor *)subtitleDisabledColor
{
    return [UIColor lightGrayColor];
}

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    [self initialize];
    [self updateTitle];
}

@end
