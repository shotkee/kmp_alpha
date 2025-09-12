#import <YandexMapsMobile/YMKLocationLocationManager.h>
#import <YandexMapsMobile/YRTExport.h>

@class YMKLocation;

/**
 * Provides the ability to set any location and notify all consumers of
 * this location.
 *
 * This is a very simple location manager that is responsible for
 * passing any locations via setLocation method and notifying all
 * consumers.
 *
 * Note: The main reason why we need this class is to allow the user to
 * set this LocationManager to Guide via setLocationManager, just to
 * correct any desirable location via Guide.
 */
YRT_EXPORT @interface YMKDummyLocationManager : YMKLocationManager

/**
 * Sets a location and notifies all consumers of this location.
 *
 * @param location Any desirable location that we would like to provide.
 */
- (void)setLocationWithLocation:(nonnull YMKLocation *)location;

@end
