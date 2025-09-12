#import <YandexMapsMobile/YMKLocationLocationListener.h>
#import <YandexMapsMobile/YRTExport.h>

@class YMKLocation;

/**
 * Undocumented
 */
typedef NS_ENUM(NSUInteger, YMKLocationFilteringMode) {
    /**
     * Locations should be filtered (no unrealistic or spoofed locations, or
     * locations from the past).
     */
    YMKLocationFilteringModeOn,
    /**
     * Only invalid (i.e. zero) locations should be filtered.
     */
    YMKLocationFilteringModeOff
};

/**
 * Handles location updates and changes.
 */
YRT_EXPORT @interface YMKLocationManager : NSObject

/**
 * Subscribe for location update events. If the listener was already
 * subscribed to updates from the LocationManager, subscription settings
 * will be updated. Use desiredAccuracy = 0 to obtain best possible
 * accuracy, minTime = 0 to ignore minTime and use minDistance instead,
 * minDistance = 0 to use only minTime. If both minTime and minDistance
 * are set to zero, the subscription will use the same settings as other
 * LocationManager clients.
 *
 * @param desiredAccuracy Desired location accuracy, in meters. This
 * value is used to configure location services provided by the host OS.
 * If locations with the desired accuracy are not available, updates may
 * be called with lower accuracy.
 * @param minTime Minimal time interval between events, in milliseconds.
 * @param minDistance Minimal distance between location updates, in
 * meters.
 * @param allowUseInBackground Defines whether the subscription can
 * continue to fetch notifications when the application is inactive. If
 * allowUseInBackground is true, set the `location` flag in
 * `UIBackgroundModes` for your application.
 * @param filteringMode Defines whether locations should be filtered.
 * @param locationListener Location update listener.
 */
- (void)subscribeForLocationUpdatesWithDesiredAccuracy:(double)desiredAccuracy
                                               minTime:(long long)minTime
                                           minDistance:(double)minDistance
                                  allowUseInBackground:(BOOL)allowUseInBackground
                                         filteringMode:(YMKLocationFilteringMode)filteringMode
                                      locationListener:(nonnull id<YMKLocationDelegate>)locationListener;

/**
 * Subscribe to a single location update. If the listener was already
 * subscribed to location updates, the previous subscription will be
 * removed.
 *
 * @param locationListener Location update listener.
 */
- (void)requestSingleUpdateWithLocationListener:(nonnull id<YMKLocationDelegate>)locationListener;

/**
 * Unsubscribe from location update events. Can be called for either
 * subscribeForLocationUpdates() or requestSingleUpdate(). For
 * requestSingleUpdate(), if an event was already received,
 * unsubscribe() does not have any effect. If the listener is already
 * unsubscribed, the method call is ignored.
 *
 * @param locationListener Listener passed to either
 * subscribeForLocationUpdates() or requestSingleUpdate().
 */
- (void)unsubscribeWithLocationListener:(nonnull id<YMKLocationDelegate>)locationListener;

/**
 * Stops updates for all subscriptions until resume() is called.
 */
- (void)suspend;

/**
 * Resumes updates stopped by a suspend() call.
 */
- (void)resume;

@end

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKLocationManager (LocationManagerUtils)

+ (nullable YMKLocation *)lastKnownLocation;

@end

