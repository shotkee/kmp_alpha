//
//  NSString+RMRHelper.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "NSString+RMRHelper.h"


@implementation NSString (RMRHelper)

+ (BOOL)RMR_isEmail:(NSString *)emailCandidate
{
    emailCandidate = [emailCandidate lowercaseString];
    
    NSString *emailRegEx =
        @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
        @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

    NSPredicate *regExPredicate =
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    return [regExPredicate evaluateWithObject:emailCandidate];
}

- (BOOL)RMR_isEmail { return [NSString RMR_isEmail:self]; }

+ (NSString *)RMR_exceptionReasonConstructor:(Class)exc_class
                                     message:(SEL)exc_selector
                                        body:(NSString *)exc_body
{
    return [NSString stringWithFormat:
            @"\n\tClass: %@\n\tMessage: %@\n\tReason: %@",
            NSStringFromClass(exc_class),
            NSStringFromSelector(exc_selector),
            exc_body];
}

@end
