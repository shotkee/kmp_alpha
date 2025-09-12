//
//  RMRNavigationController.h
//  AlfaStrah
//
//  Created by Roman Churkin on 17/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

@import UIKit;

@interface RMRNavigationController : UINavigationController

@property (nullable, nonatomic, strong) id<UINavigationControllerDelegate> strongDelegate;

@end
