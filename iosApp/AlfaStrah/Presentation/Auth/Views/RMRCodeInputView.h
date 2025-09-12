//
//  RMRCodeInputView.h
//  AlfaStrah
//
//  Created by Roman Churkin on 17.03.14.
//  Copyright (c) 2014 RedMadRobot. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef void(^RMRCodeInputViewGotFullCode)(NSString *fullCode);

/**
 Контрол для ввода цифрового кода заданной длины.
 
 Абстрактный. Наследники должны переопределить методы:
 
 - updateColors  Инициализация контрола

 - createElementView
 
 - clear  Очистка поля.
 
 - codeUpdate:
 */
@interface RMRCodeInputView : UIView

/**
 Элементы поля.
 */
@property (nonatomic, strong) NSArray *elementViews;

/**
 Блок, который будет выполнен в случае полного заполнения поля.
 */
@property (nonatomic, copy, nullable) RMRCodeInputViewGotFullCode gotFullCode;

/**
 Сконфигурировать RMRCodeInputView для необходимой длины кода.
 
 @param length Из скольки символов должен состоять код.
 */
- (void)configureForCodeLength:(NSUInteger)length;

/**
 Текущее значение поля.
 */
@property (nonatomic, copy, readonly) NSString *currentValue;

/**
 Смена текущего значения кода
 
 @param newCode Новое значение введенного кода. Если длина кода больше заданной, то новый код будет обрезан с конца.
 */
- (void)changeCurrentCode:(NSString *)newCode;

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame;

- (void)awakeFromNib;

- (BOOL)becomeFirstResponder;

- (BOOL)resignFirstResponder;

- (void)updateConstraints;

#pragma mark - Methods to override

/**
 Инициализация контрола.
 */
- (void)initialization NS_REQUIRES_SUPER;

/**
 Очистить поле.
 */
- (void)clear NS_REQUIRES_SUPER;

- (void)backspace;

/**
 Создание view для каждого элемента.

 Вызывается для каждого элемента поля. Например, UITextField для каждой цифры.

 Метод должен быть переопределен наследниками.
 
 @return View элемента поля.
 */
- (UIView *)createElementView;

/**
 Обновление строки кода.

 Вызывается когда пользователь добавил или удалил символ кода.

 Метод должен быть переопределен наследниками.

 @param newCodeString Новое значение кода.
 */
- (void)codeUpdate:(NSString *)newCodeString;

@end

NS_ASSUME_NONNULL_END
