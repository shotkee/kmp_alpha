#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

@class YMKLocationManager;
@class YMKLocationViewSource;

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKLocationViewSourceFactory : NSObject

/**
 * Location view source.
 */
+ (nonnull YMKLocationViewSource *)createLocationViewSourceWithLocationManager:(nonnull YMKLocationManager *)locationManager;

@end

