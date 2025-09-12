//
//  NSString+RMRHelper.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (RMRHelper)

+ (BOOL)RMR_isEmail:(NSString *)emailCandidate;

- (BOOL)RMR_isEmail;

+ (NSString *)RMR_exceptionReasonConstructor:(Class)exc_class
                                     message:(SEL)exc_selector
                                        body:(NSString *)exc_body;

@end
