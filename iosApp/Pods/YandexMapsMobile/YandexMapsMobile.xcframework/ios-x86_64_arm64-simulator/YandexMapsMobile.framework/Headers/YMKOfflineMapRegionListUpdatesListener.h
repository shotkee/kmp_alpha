#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * @attention This feature is not available in the free MapKit version.
 *
 *
 * Listener to handle region list updated
 */
@protocol YMKOfflineMapRegionListUpdatesListener <NSObject>

/**
 * Undocumented
 */
- (void)onListUpdated;

@end
