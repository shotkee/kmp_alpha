#import <YandexMapsMobile/YMKGestureFocusPointMode.h>
#import <YandexMapsMobile/YMKMapSizeChangedListener.h>
#import <YandexMapsMobile/YMKPoint.h>
#import <YandexMapsMobile/YMKPointOfView.h>
#import <YandexMapsMobile/YMKScreenTypes.h>
#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

@class YMKMap;
@class YMKMapWindow;
@class YMKVisibleRegion;

/**
 * Handles the MapWindow element.
 */
YRT_EXPORT @interface YMKMapWindow : NSObject
/**
 * Gets the map interface.
 */
@property (nonatomic, readonly, readonly, nonnull) YMKMap *map;

/**
 * Screen width in physical pixels
 */
- (NSInteger)width;

/**
 * Screen height in physical pixels
 */
- (NSInteger)height;

/**
 * Transforms the position from world coordinates to screen coordinates.
 *
 * @param worldPoint Latitude and longitude information.
 *
 * @return The point in screen space corresponding to worldPoint;
 * returns none if the point is behind the camera.
 */
- (nullable YMKScreenPoint *)worldToScreenWithWorldPoint:(nonnull YMKPoint *)worldPoint;

/**
 * Transforms coordinates from screen space to world space.
 *
 * @param screenPoint The point in screen coordinates relative to the
 * top left of the map. These coordinates are in physical pixels and not
 * in device independent (virtual) pixels.
 *
 * @return Latitude and longitude information.
 */
- (nullable YMKPoint *)screenToWorldWithScreenPoint:(nonnull YMKScreenPoint *)screenPoint;
/**
 * When using controls that overlay the map view, calculating the proper
 * camera position can be tricky. This property simplifies the task by
 * defining the area of interest (the focus rectangle) inside the view.
 * Map methods that calculate the camera position based on a world
 * bounding box ensure that this bounding box will fit into the
 * focusRect.
 *
 * For example, when using a semi-transparent control that overlays the
 * top half of the map view, define the focus rectangle as the lower
 * half of the view to ensure that object of interest appear in the
 * lower half of map view. In addition, if focusPoint is null all camera
 * movements will have the center of the lower half as their target.
 *
 * If focusRect is null, the whole map view is used instead.
 *
 * On iOS, if you change the focus rectangle in the
 * viewDidLayoutSubviews callback, it's recommended to call
 * MapView.layoutIfNeeded just before that action.
 *
 * Optional property, can be nil.
 */
@property (nonatomic, nullable) YMKScreenRect *focusRect;
/**
 * The point on the screen that corresponds to camera position. Changing
 * camera position or focusPoint makes the new camera target appear
 * exactly at the focusPoint on screen.
 *
 * If focusPoint is null, the center of focusRect is used instead.
 *
 * Optional property, can be nil.
 */
@property (nonatomic, nullable) YMKScreenPoint *focusPoint;
/**
 * Defines the focus point of gestures. Actual behaviour depends on
 * gestureFocusPointMode. If the point is not set, the source point of
 * the gesture will be used as the focus point. Default: none.
 *
 * Optional property, can be nil.
 */
@property (nonatomic, nullable) YMKScreenPoint *gestureFocusPoint;
/**
 * Specifies the way provided gesture focus point affects gestures.
 * Default: TapGestures.
 */
@property (nonatomic) YMKGestureFocusPointMode gestureFocusPointMode;
/**
 * Defines the position of the point of view. Cameras use perspective
 * projection, which causes perspective deformations. Perspective
 * projection has an axis, and points on this axis are not affected by
 * perspective deformations. This axis is a line parallel to the view's
 * direction, so its projection to the screen is a point - the "point of
 * view". By default, this point is at the center of the screen, but
 * some applications might want to set it to the center of focusRect.
 * Use this flag to do so. Default: ScreenCenter
 */
@property (nonatomic) YMKPointOfView pointOfView;
/**
 * Sets the vertical field of view, in degrees. Default: 30.
 */
@property (nonatomic) double fieldOfViewY;
/**
 * Gets the focused region.
 *
 * @return A region that corresponds to the current focusRect or the
 * visible region if focusRect is not set. Region IS bounded by latitude
 * limits [-90, 90] and IS NOT bounded by longitude limits [-180, 180].
 * If longitude exceeds its limits, we see the world's edge and another
 * instance of the world beyond this edge.
 */
@property (nonatomic, readonly, nonnull) YMKVisibleRegion *focusRegion;

/**
 * Adds a SizeChangedListener.
 */
- (void)addSizeChangedListenerWithSizeChangedListener:(nonnull id<YMKMapSizeChangedListener>)sizeChangedListener;

/**
 * Removes a SizeChangedListener.
 */
- (void)removeSizeChangedListenerWithSizeChangedListener:(nonnull id<YMKMapSizeChangedListener>)sizeChangedListener;
/**
 * Defines the scale factor, which equals the number of pixels per
 * device-independent point.
 */
@property (nonatomic) float scaleFactor;

/**
 * Caps FPS. Valid range: (0, 60]. Default: 60.
 */
- (void)setMaxFpsWithFps:(float)fps;

/**
 * Called on memory warning.
 */
- (void)onMemoryWarning;

/**
 * :nodoc:
 * Starts capturing performance metrics.
 */
- (void)startPerformanceMetricsCapture;

/**
 * :nodoc:
 * Stops capturing performance metrics and returns captured metrics as a
 * string.
 */
- (nonnull NSString *)stopPerformanceMetricsCapture;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKOffscreenMapWindow : NSObject
/**
 * Undocumented
 */
@property (nonatomic, readonly, readonly, nonnull) YMKMapWindow *mapWindow;

/**
 * Undocumented
 */
- (nonnull UIImage *)captureScreenshot;

@end
