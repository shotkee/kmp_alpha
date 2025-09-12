//
//  RMRSimpleDateFormatter.m
//  AlfaStrah
//
//  Created by Stanislav on 27/02/2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

#import "RMRSimpleDateFormatter.h"

@implementation RMRSimpleDateFormatter

+ (NSString *)existingTimeFromString:(NSString *)timeString separator:(NSString *)separator {
    NSString *retVal = timeString;
    NSArray *cmp = [timeString componentsSeparatedByString:separator];
    
    if (cmp.count == 2) {
        NSString *hour = cmp[0];
        NSString *minute = cmp[1];
        
        if (hour.integerValue < 0) {
            hour = @"0";
        } else if (hour.integerValue > 23) {
            hour = @"23";
        }
        
        if (minute.integerValue < 0) {
            minute = @"0";
        } else if (minute.integerValue > 59) {
            minute = @"59";
        }
        
        retVal = [NSString stringWithFormat:@"%@%@%@", hour, separator, minute];
    }
    
    return retVal;
}

+ (NSString *)existingDateInPastFromString:(NSString *)dateString separator:(NSString *)separator
{
    NSArray *cmp = [dateString componentsSeparatedByString:separator];
    
    NSString *retVal = nil;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *dc = [NSDateComponents new];
    
    switch (cmp.count) {
        case 1:{
            if ([cmp[0] length] < 2) {
                return dateString;
            }
            
            NSString *day = cmp[0];
            NSString *month = nil;
            BOOL shouldAppendMonth = day.length > 2;
            if (shouldAppendMonth) {
                day = [cmp[0] substringToIndex:2];
                month = [cmp[0] substringFromIndex:2];
            }
            
            retVal = dateString;
            
            if (day.integerValue < 1) {
                retVal = @"1";
            } else if (day.integerValue > 31) {
                retVal = @"31";
            }
            
            if (shouldAppendMonth) {
                retVal = [NSString stringWithFormat:@"%@%@%@", day, separator, month];
            }
        }
            break;
        case 2: {
            if ([cmp[1] length] < 2) {
                return dateString;
            }
            
            BOOL shouldAppendYear = [cmp[1] length] > 2;
            
            NSInteger day = [cmp[0] integerValue];
            NSInteger month = 0;
            NSString *yearStr = nil;
            if (shouldAppendYear) {
                NSString *mstr = [cmp[1] substringToIndex:2];
                yearStr = [cmp[1] substringFromIndex:2];
                month = [mstr integerValue];
            } else {
                month = [cmp[1] integerValue];
            }
            NSInteger year = 2016; // 29 days in feb
            
            month = MAX(1, month);
            month = MIN(12, month);
            
            
            dc.year = year;
            dc.month = month;
            NSDate *d = [cal dateFromComponents:dc];
            NSInteger maxDays = [cal rangeOfUnit:NSCalendarUnitDay
                                          inUnit:NSCalendarUnitMonth
                                         forDate:d].length;
            
            day = MAX(1, day);
            day = MIN(maxDays, day);
            
            NSString *dayStr = day < 10 ? [NSString stringWithFormat:@"0%ld", (long)day] : @(day).stringValue;
            NSString *monthStr = month < 10 ? [NSString stringWithFormat:@"0%ld", (long)month] : @(month).stringValue;
            retVal = [NSString stringWithFormat:@"%@%@%@", dayStr, separator, monthStr];
            if (shouldAppendYear) {
                retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"%@%@", separator, yearStr]];
            }
        }
            break;
        case 3: {
            if ([cmp[2] length] < 4) {
                return dateString;
            }
            
            NSInteger day = [cmp[0] integerValue];
            NSInteger month = [cmp[1] integerValue];
            NSInteger year = [cmp[2] integerValue];
            
            NSDate *now = [NSDate date];
            NSInteger currentYear = [cal component:NSCalendarUnitYear fromDate:now];
            
            year = MIN(currentYear, year);
            year = MAX((currentYear - 200), year);
            // month is already fine
            
            dc.year = year;
            dc.month = month;
            
            NSDate *d = [cal dateFromComponents:dc];
            NSInteger maxDays = [cal rangeOfUnit:NSCalendarUnitDay
                                          inUnit:NSCalendarUnitMonth
                                         forDate:d].length;
            
            day = MIN(maxDays, day);
            
            dc.day = day;
            NSDate *resDate = [cal dateFromComponents:dc];
            
            if ([now isEqual:[now earlierDate:resDate]]) {
                // we're in future, travel back in time
                day = [cal component:NSCalendarUnitDay fromDate:now];
                month = [cal component:NSCalendarUnitMonth fromDate:now];
            }
            
            NSString *dayStr = day < 10 ? [NSString stringWithFormat:@"0%ld", (long)day] : @(day).stringValue;
            NSString *monthStr = month < 10 ? [NSString stringWithFormat:@"0%ld", (long)month] : @(month).stringValue;
            retVal = [NSString stringWithFormat:@"%@%@%@%@%ld", dayStr, separator, monthStr, separator, (long)year];
        }
            break;
        default:
            break;
    }
    
    return retVal;
}

+ (NSDate *)dateFromString:(NSString *)string separator:(NSString *)separator
{
    
    NSArray *cmp = [string componentsSeparatedByString:separator];
    if (cmp.count < 3) {
        return nil;
    } else if ([cmp[2] length] < 4) {
        return nil;
    }
    
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    NSDateComponents *dc = [NSDateComponents new];
    dc.day = [cmp[0] integerValue];
    dc.month = [cmp[1] integerValue];
    dc.year = [cmp[2] integerValue];
    
    NSDate *retVal = [cal dateFromComponents:dc];
    return retVal;
}

@end
