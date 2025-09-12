#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Time in I18nTime format.
 */
YRT_EXPORT @interface YMKTime : NSObject

/**
 * Time value.
 */
@property (nonatomic, readonly) long long value;

/**
 * Time offset to account for time zones.
 */
@property (nonatomic, readonly) NSInteger tzOffset;

/**
 * The description of the timer.
 */
@property (nonatomic, readonly, nonnull) NSString *text;


+ (nonnull YMKTime *)timeWithValue:( long long)value
                          tzOffset:( NSInteger)tzOffset
                              text:(nonnull NSString *)text;


@end
