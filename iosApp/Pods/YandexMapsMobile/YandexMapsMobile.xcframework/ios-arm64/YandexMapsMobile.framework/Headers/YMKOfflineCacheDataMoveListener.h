#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * @attention This feature is not available in the free MapKit version.
 *
 *
 * Listener for the information about operations.
 */
@protocol YMKOfflineCacheDataMoveListener <NSObject>

/**
 * Called when the operation makes progress. Percent is the rate of
 * completion in the range of 0 to 100.
 */
- (void)onDataMoveProgressWithPercent:(NSInteger)percent;

/**
 * Called when the request is completed.
 */
- (void)onDataMoveCompleted;

/**
 * Called when an error occurs.
 */
- (void)onDataMoveErrorWithError:(nonnull NSError *)error;

@end
