#import <YandexMapsMobile/YMKAnimation.h>
#import <YandexMapsMobile/YMKCallback.h>
#import <YandexMapsMobile/YMKMapObjectDragListener.h>
#import <YandexMapsMobile/YMKMapObjectTapListener.h>
#import <YandexMapsMobile/YRTExport.h>

@class YMKBaseMapObjectCollection;

/**
 * An object displayed on the map.
 */
YRT_EXPORT @interface YMKMapObject : NSObject
/**
 * Returns the collection of map objects that the current map object
 * belongs to.
 */
@property (nonatomic, readonly, readonly, nonnull) YMKBaseMapObjectCollection *parent;
/**
 * Manages visibility of the object on the map. Default: true.
 */
@property (nonatomic, getter=isVisible) BOOL visible;

/**
 * Manages visibility of the object.
 *
 * @param animation Describes the transition between visible and not
 * visible states.
 * @param onFinished Called when the transition is finished.
 *
 * Remark:
 * @param onFinished has optional type, it may be uninitialized.
 */
- (void)setVisibleWithVisible:(BOOL)visible
                    animation:(nonnull YMKAnimation *)animation
                     callback:(nullable YMKCallback)callback;
/**
 * Gets the z-index, which affects: 1) Rendering order. 2) Dispatching
 * of UI events (taps and drags are dispatched to objects with higher
 * z-indexes first). Z-index is relative to the parent.
 */
@property (nonatomic) float zIndex;
/**
 * If true, the map object can be dragged by the user. Default: false.
 */
@property (nonatomic, getter=isDraggable) BOOL draggable;
/**
 * Use this property to attach any object-related metadata.
 *
 * Optional property, can be nil.
 */
@property (nonatomic, nullable) id userData;

/**
 * Adds a tap listener to the object.
 */
- (void)addTapListenerWithTapListener:(nonnull id<YMKMapObjectTapListener>)tapListener;

/**
 * Removes the tap listener from the object.
 */
- (void)removeTapListenerWithTapListener:(nonnull id<YMKMapObjectTapListener>)tapListener;

/**
 * Sets a drag listener for the object. Each object can only have one
 * drag listener.
 *
 * Remark:
 * @param dragListener has optional type, it may be uninitialized.
 */
- (void)setDragListenerWithDragListener:(nullable id<YMKMapObjectDragListener>)dragListener;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
