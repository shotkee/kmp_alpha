#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

@class YMKCameraPosition;
@class YMKMap;

/**
 * Listener for user interactions with the map.
 */
@protocol YMKInertiaMoveListener <NSObject>

/**
 * Called when an inertia move is started.
 *
 * @param finishCameraPosition Approximate position of camera when the
 * inertia move finishes.
 */
- (void)onStartWithMap:(nonnull YMKMap *)map
  finishCameraPosition:(nonnull YMKCameraPosition *)finishCameraPosition;

/**
 * Called when inertia move is cancelled.
 *
 * @param cameraPosition Current camera position.
 */
- (void)onCancelWithMap:(nonnull YMKMap *)map
         cameraPosition:(nonnull YMKCameraPosition *)cameraPosition;

/**
 * Called when inertia move is finished.
 *
 * @param cameraPosition Current camera position.
 */
- (void)onFinishWithMap:(nonnull YMKMap *)map
         cameraPosition:(nonnull YMKCameraPosition *)cameraPosition;

@end
