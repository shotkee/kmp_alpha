//
//  RMRSimpleDateFormatter.h
//  AlfaStrah
//
//  Created by Stanislav on 27/02/2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMRSimpleDateFormatter : NSObject

+ (NSString *)existingTimeFromString:(NSString *)timeString separator:(NSString *)separator;
+ (NSString *)existingDateInPastFromString:(NSString *)dateString separator:(NSString *)separator;
+ (NSDate *)dateFromString:(NSString *)string separator:(NSString *)separator;

@end
