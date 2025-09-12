#import <YandexMapsMobile/YMKLayerLoadedListener.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Interface for working with the layer.
 */
YRT_EXPORT @interface YMKLayer : NSObject

/**
 * Shows or hides the layer on the map.
 */
- (void)activateWithOn:(BOOL)on;

/**
 * Invalidates the layer and reloads all tiles that have been modified
 * in the new map version. To update a layer that does not have a
 * version, leave this parameter empty. Can be called on any thread.
 */
- (void)invalidateWithVersion:(nonnull NSString *)version;

/**
 * Clears all cached tiles and starts new requests for tiles that are
 * displayed.
 */
- (void)clear;

/**
 * Removes the layer from the map.
 */
- (void)remove;

/**
 * Applies JSON style transformation to the layer. Replaces previous
 * styling with the specified ID (if such exists). Stylings are applied
 * in an ascending order. Set to empty string to clear previous styling
 * with the specified ID. Returns true if the style was successfully
 * parsed and false otherwise. If the returned value is false, the
 * current style remains unchanged.
 */
- (BOOL)setStyleWithId:(NSInteger)id
                 style:(nonnull NSString *)style;

/**
 * Resets all JSON style transformations applied to the layer.
 */
- (void)resetStyles;

/**
 * Sets layer loaded listener.
 *
 * Remark:
 * @param layerLoadedListener has optional type, it may be
 * uninitialized.
 */
- (void)setLayerLoadedListenerWithLayerLoadedListener:(nullable id<YMKLayerLoadedListener>)layerLoadedListener;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
