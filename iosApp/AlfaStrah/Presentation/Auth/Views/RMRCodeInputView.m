//
//  RMRCodeInputView.m
//  AlfaStrah
//
//  Created by Roman Churkin on 17.03.14.
//  Copyright (c) 2014 RedMadRobot. All rights reserved.
//

#import "RMRCodeInputView.h"

@interface RMRCodeInputView ()<UITextFieldDelegate>

@property (nonatomic, weak) UITextField *codeTextField;

@end

@implementation RMRCodeInputView

- (void)initialization {
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, .5f)];
    separatorView.backgroundColor = [UIColor lightGrayColor];

    UITextField *codeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    codeTextField.inputAccessoryView = separatorView;
    codeTextField.hidden = YES;
    codeTextField.delegate = self;
    codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [codeTextField addTarget:self action:@selector(passCodeChanged:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:codeTextField];
    self.codeTextField = codeTextField;

    [codeTextField setContentHuggingPriority:100 forAxis:UILayoutConstraintAxisHorizontal];
    [codeTextField setContentHuggingPriority:100 forAxis:UILayoutConstraintAxisVertical];

    [codeTextField setContentCompressionResistancePriority:100 forAxis:UILayoutConstraintAxisHorizontal];
    [codeTextField setContentCompressionResistancePriority:100 forAxis:UILayoutConstraintAxisVertical];

    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginEditing:)]];
}

- (instancetype)init {
    self = [super init];
    [self initialization];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initialization];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self initialization];
}

- (BOOL)becomeFirstResponder {
    return [self.codeTextField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];

    return [self.codeTextField resignFirstResponder];
}

- (void)updateConstraints {
    self.codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.codeTextField.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.codeTextField.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.codeTextField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.codeTextField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]
    ]];

    [super updateConstraints];
}

#pragma mark - Configuration

- (void)configureForCodeLength:(NSUInteger)length {
    self.codeTextField.text = nil;
    [self.elementViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSMutableArray *elementViews = [NSMutableArray arrayWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        UIView *elementView = [self createElementView];
        [self addSubview:elementView];
        [elementViews addObject:elementView];
    }

    self.elementViews = [NSArray arrayWithArray:elementViews];
    [self setNeedsLayout];
}

- (void)clear {
    self.codeTextField.text = nil;
}

- (void)backspace {
    NSString *currentCode = self.codeTextField.text ?: @"";
    if (currentCode.length == 0) {
        return;
    }
    NSString *newCode = [currentCode substringToIndex:[currentCode length] - 1];
    self.codeTextField.text = newCode;
    [self codeUpdate:newCode];
}

- (NSString *)currentValue {
    return self.codeTextField.text ?: @"";
}

- (void)changeCurrentCode:(NSString *)newCode {
    NSUInteger maxCodeLength = self.elementViews.count;
    if (newCode.length > maxCodeLength) {
        newCode = [newCode substringToIndex:maxCodeLength];
    }
    self.codeTextField.text = newCode;
    [self passCodeChanged:self.codeTextField];
}

#pragma mark - Actions

- (void)passCodeChanged:(UITextField *)textField {
    [self codeUpdate:textField.text];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        if (textField.text.length == self.elementViews.count && self.gotFullCode) {
            self.gotFullCode(textField.text ?: @"");
        }
    });
}

- (void)beginEditing:(id)sender {
    [self.codeTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return range.location < self.elementViews.count;
}

#pragma mark - Methods to override

- (UIView *)createElementView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Abstract method from superclass not implemented."
                                 userInfo:nil];
}

- (void)codeUpdate:(NSString *)newCodeString {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Abstract method from superclass not implemented."
                                 userInfo:nil];
}

@end
