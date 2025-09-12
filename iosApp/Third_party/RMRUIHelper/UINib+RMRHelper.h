//
//  UINib+RMRHelper.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINib (RMRHelper)

/**
 Метод возвращает nib с указанным именем, если такой существует. Иначе nil
 */
+ (UINib *)RMR_nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil;

@end
