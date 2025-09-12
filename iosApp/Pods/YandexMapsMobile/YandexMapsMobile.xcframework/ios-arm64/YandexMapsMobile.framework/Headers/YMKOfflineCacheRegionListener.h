#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * @attention This feature is not available in the free MapKit version.
 *
 *
 * Listener to handle region information.
 */
@protocol YMKOfflineCacheRegionListener <NSObject>

/**
 * Region state was changed.
 */
- (void)onRegionStateChangedWithRegionId:(NSUInteger)regionId;

/**
 * Progress of specific region download was updated.
 */
- (void)onRegionProgressWithRegionId:(NSUInteger)regionId;

@end
