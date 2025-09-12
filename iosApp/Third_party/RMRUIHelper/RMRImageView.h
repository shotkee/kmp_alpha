//
//  RMRImageView.h
//  AlfaStrah
//
//  Created by Roman Churkin on 17/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

@import UIKit;

/**
 В iOS 7 и iOS 8 отрисовка изображений в UIImageView из Storyboard сломана
 и работает через раз. Изображение либо не получает верный rendering mode (iOS 7),
 либо не устанавливает tintColor (iOS 8). Этот класс обходит проблему.

 Так же класс добавляет отрисовку изображения в tintColor в Storyboard.
 */
@interface RMRImageView : UIImageView

- (void)prepareForInterfaceBuilder NS_REQUIRES_SUPER;

@end
