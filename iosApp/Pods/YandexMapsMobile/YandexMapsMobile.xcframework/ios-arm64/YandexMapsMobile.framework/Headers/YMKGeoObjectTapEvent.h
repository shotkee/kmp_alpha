#import <YandexMapsMobile/YMKGeoObject.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Information about the tapped object.
 */
YRT_EXPORT @interface YMKGeoObjectTapEvent : NSObject
/**
 * @Returns The object that was tapped.
 */
@property (nonatomic, readonly, nonnull) YMKGeoObject *geoObject;
/**
 * @deprecated Use selectGeoObject method instead.
 */
@property (nonatomic, getter=isSelected) BOOL selected;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
