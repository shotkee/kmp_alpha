//
//  RMRSelfCalculateHeightView.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 30/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Протокол для объектов, которые умеют высчитывать высоту по заданной ширине
 */
@protocol RMRSelfCalculateHeightView <NSObject>

@required

/**
 Методя возвращает требуюмую для объекта высоту при заданной ширине
 */
- (CGFloat)requiredHeightForWidth:(CGFloat)width;

@end
