//
//  UINib+RMRHelper.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "UINib+RMRHelper.h"


@implementation UINib (RMRHelper)

+ (UINib *)RMR_nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil
{
    // MARK: согласно документации, так должен работать оригинальный метод nibWithNibName:bundle Однако, он возвращает некоторую сущность, несмотря на отсутствие в bundle nib с указанным именем. Пришлось реализовать обертку.
    if (!name || name.length == 0) {
        return nil;
    } else {
        if (!bundleOrNil) {
            bundleOrNil = [NSBundle mainBundle];
        }

        NSString *pathForResource = [bundleOrNil pathForResource:name ofType:@"nib"];

        BOOL gotNib = pathForResource != nil && pathForResource.length > 0;

        if (gotNib) {
            return [UINib nibWithNibName:name bundle:bundleOrNil];
        } else {
            return nil;
        }
    }
}

@end
