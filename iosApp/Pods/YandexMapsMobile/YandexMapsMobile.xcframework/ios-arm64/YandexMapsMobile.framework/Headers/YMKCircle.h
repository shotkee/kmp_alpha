#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKMapObject.h>
#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

/**
 * The circle element.
 */
YRT_EXPORT @interface YMKCircleMapObject : YMKMapObject
/**
 * Undocumented
 */
@property (nonatomic, nonnull) YMKCircle *geometry;
/**
 * Sets the stroke color. Setting the stroke color to any transparent
 * color (for example, RGBA code 0x00000000) effectively disables the
 * stroke.
 */
@property (nonatomic, nonnull) UIColor *strokeColor;
/**
 * Sets the stroke width in units. The size of a unit is equal to the
 * size of a pixel at the current zoom level when the camera position's
 * tilt is equal to 0 and the scale factor is equal to 1.
 */
@property (nonatomic) float strokeWidth;
/**
 * Sets the fill color.
 */
@property (nonatomic, nonnull) UIColor *fillColor;
/**
 * The object's geometry can be interpreted in two different ways: 1) If
 * the object mode is 'geodesic', the object's geometry is defined on a
 * sphere. 2) Otherwise, the object's geometry is defined in projected
 * space. Default: false.
 */
@property (nonatomic, getter=isGeodesic) BOOL geodesic;

@end
