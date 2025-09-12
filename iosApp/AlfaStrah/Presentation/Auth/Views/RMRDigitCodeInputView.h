//
//  RMRDigitCodeInputView.h
//  AlfaStrah
//
//  Created by Roman Churkin on 12.05.14.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRCodeInputView.h"

@interface RMRDigitCodeInputView : RMRCodeInputView

#pragma mark - Properties

/**
 Шрифт элементов цифрового кода кода.
 */
@property (strong, nonatomic) UIFont *font;

/**
 Цвет элементов цифрового кода кода.
 */
@property (strong, nonatomic) UIColor *textColor;


#pragma mark - Overrided Methods

- (void)initialization;

- (void)clear;

- (UIView *)createElementView;

- (void)codeUpdate:(NSString *)newCodeString;

@end
