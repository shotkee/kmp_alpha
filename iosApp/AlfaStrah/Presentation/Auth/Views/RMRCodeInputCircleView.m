//
//  RMRCodeInputCircleView.m
//  Pods
//
//  Created by Roman Churkin on 20/04/15.
//

#import "RMRCodeInputCircleView.h"

// View
#import "RMRRoundView.h"


@interface RMRCodeInputCircleView ()

#pragma mark — Properties

@property (nonatomic, weak) RMRRoundView *roundView;

@end


@implementation RMRCodeInputCircleView

- (void)initialize
{
    RMRRoundView *roundView = [[RMRRoundView alloc] initWithFrame:CGRectZero];
    roundView.translatesAutoresizingMaskIntoConstraints = NO;
    roundView.backgroundColor = self.tintColor;
    [self addSubview:roundView];
    self.roundView = roundView;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    [self initialize];

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self initialize];

    return self;
}

- (void)tintColorDidChange { self.roundView.backgroundColor = self.tintColor; }

- (void)updateConstraints
{
    RMRRoundView *roundView = self.roundView;
    roundView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [roundView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [roundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [roundView.heightAnchor constraintEqualToAnchor:roundView.widthAnchor],
        [roundView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]
    ]];

    [super updateConstraints];
}

@end
