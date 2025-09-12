//
//  RMRCircleCodeInputView.h
//  AlfaStrah
//
//  Created by Roman Churkin on 18.03.14.
//  Copyright (c) 2014 RedMadRobot. All rights reserved.
//

#import "RMRCodeInputView.h"

@interface RMRCircleCodeInputView : RMRCodeInputView

@property (nonatomic, assign) IBInspectable CGFloat circleDiameter;
@property (nonatomic, assign) IBInspectable CGFloat circlePadding;

@property (nonatomic, strong) IBInspectable UIColor *emptyColor;
@property (nonatomic, strong) IBInspectable UIColor *filledColor;

@end
