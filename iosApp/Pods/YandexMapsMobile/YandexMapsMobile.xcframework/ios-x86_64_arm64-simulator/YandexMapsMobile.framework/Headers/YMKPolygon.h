#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKMapObject.h>
#import <YandexMapsMobile/YRTAnimatedImageProvider.h>
#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

/**
 * A polygon displayed on the map.
 */
YRT_EXPORT @interface YMKPolygonMapObject : YMKMapObject
/**
 * Undocumented
 */
@property (nonatomic, nonnull) YMKPolygon *geometry;
/**
 * Sets the stroke color. Default: hexademical RGBA code 0x0066FFFF.
 * Setting the stroke color to any transparent color (for example, RGBA
 * code 0x00000000) effectively disables the stroke.
 */
@property (nonatomic, nonnull) UIColor *strokeColor;
/**
 * Sets the stroke width in units. Default: 5. The size of a unit is
 * equal to the size of a pixel at the current zoom when the camera
 * position's tilt is equal to 0 and the scale factor is equal to 1.
 */
@property (nonatomic) float strokeWidth;
/**
 * Sets the fill color. Default: hexademical RGBA code 0x0066FF99. Note:
 * fill color is ignored if an animated image is set.
 */
@property (nonatomic, nonnull) UIColor *fillColor;
/**
 * The object geometry can be interpreted in two different ways: 1) If
 * the object mode is 'geodesic', the object geometry is defined on a
 * sphere. 2) Otherwise, the object geometry is defined in projected
 * space. Default: false.
 */
@property (nonatomic, getter=isGeodesic) BOOL geodesic;

/**
 * Sets animated pattern with provided repeat mode to fill polygon.
 * Pattern will be scaled to fit provided pattern width. Note: original
 * linear sizes of pattern should be equal to power of 2. Note: fill
 * color is ignored if an animated image is set.
 */
- (void)setAnimatedImageWithAnimatedImage:(nonnull id<YRTAnimatedImageProvider>)animatedImage
                             patternWidth:(float)patternWidth;

/**
 * Removes animated pattern.
 */
- (void)resetAnimatedImage;

@end
