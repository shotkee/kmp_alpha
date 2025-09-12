#import <YandexMapsMobile/YMKArrowTapListener.h>
#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKMapObject.h>
#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

@class YMKArrow;

/**
 * A polyline object with adjustable segment colors. Supports outlines,
 * dash, arrows, and hiding parts of the polyline efficiently.
 */
YRT_EXPORT @interface YMKPolylineMapObject : YMKMapObject
/**
 * The polyline's geometry. Should contain at least 2 points. Changing
 * geometry resets polyline color indices to 0.
 */
@property (nonatomic, nonnull) YMKPolyline *geometry;
/**
 * The stroke width in units. Default: 5. The size of a unit is equal to
 * the size of a pixel at the current zoom level when the camera
 * position's tilt is equal to 0 and the scale factor is equal to 1.
 */
@property (nonatomic) float strokeWidth;
/**
 * Maximum length (in units) of the gradient from one color to another.
 * Default: 0.
 */
@property (nonatomic) float gradientLength;
/**
 * The outline color. Default: hexademical RGBA code 0x00000000.
 */
@property (nonatomic, nonnull) UIColor *outlineColor;
/**
 * Width of the outline in units. Default: 0.
 */
@property (nonatomic) float outlineWidth;
/**
 * Enables the inner outline if true (a dark border along the edge of
 * the outline). Default: false.
 */
@property (nonatomic, getter=isInnerOutlineEnabled) BOOL innerOutlineEnabled;
/**
 * Maximum radius of a turn. Measured in units. Default: 10.
 */
@property (nonatomic) float turnRadius;
/**
 * Defines step of arc approximation. Smaller values make polyline
 * smoother. Measured in degrees. Default: 12.
 */
@property (nonatomic) float arcApproximationStep;
/**
 * Length of a dash in units. Default: 0 (dashing is turned off). Arrows
 * are ignored in dashed polylines.
 */
@property (nonatomic) float dashLength;
/**
 * Length of the gap between two dashes in units. Default: 0 (dashing is
 * turned off). Arrows are ignored in dashed polylines.
 */
@property (nonatomic) float gapLength;
/**
 * Offset from the start of the polyline to the reference dash in units.
 * Default: 0.
 */
@property (nonatomic) float dashOffset;

/**
 * Highlights a subpolyline using the specified color.
 */
- (void)selectWithSelectionColor:(nonnull UIColor *)selectionColor
                     subpolyline:(nonnull YMKSubpolyline *)subpolyline;

/**
 * Hides the subpolyline, canceling any previous hides.
 */
- (void)hideWithSubpolyline:(nonnull YMKSubpolyline *)subpolyline;

/**
 * Hides multiple subpolylines, canceling any previous hides.
 */
- (void)hideWithSubpolylines:(nonnull NSArray<YMKSubpolyline *> *)subpolylines;

/**
 * Sets indexes of colors in palette for line segments. Weights are used
 * for generalization of colors. By default, all segments use palette
 * index 0.
 */
- (void)setStrokeColorsWithColors:(nonnull NSArray<NSNumber *> *)colors
                          weights:(nonnull NSArray<NSNumber *> *)weights;

/**
 * Sets indexes of colors in palette for line segments. All the weights
 * are equal to 1.
 */
- (void)setStrokeColorsWithColors:(nonnull NSArray<NSNumber *> *)colors;

/**
 * Sets color in RGBA mode for colorIndex. If the color is not provided
 * for some index, the default value 0x0066FFFF is used.
 */
- (void)setPaletteColorWithColorIndex:(NSUInteger)colorIndex
                                color:(nonnull UIColor *)color;

/**
 * Returns the palette color for the specified index.
 */
- (nonnull UIColor *)getPaletteColorWithColorIndex:(NSUInteger)colorIndex;

/**
 * Sets the polyline color. Effectively sets a single-color palette and
 * sets all segments' palette indices to 0.
 */
- (void)setStrokeColorWithColor:(nonnull UIColor *)color;

/**
 * Returns the palette index used by segment with the specified index.
 */
- (NSUInteger)getStrokeColorWithSegmentIndex:(NSUInteger)segmentIndex;

/**
 * Adds an arrow.
 *
 * @param position Coordinates of the center of the arrow.
 * @param length Overall length of the arrow (including the tip) in
 * units.
 * @param fillColor Color of the arrow. Adding arrows disables dash for
 * this polyline.
 */
- (nonnull YMKArrow *)addArrowWithPosition:(nonnull YMKPolylinePosition *)position
                                    length:(float)length
                                 fillColor:(nonnull UIColor *)fillColor;

/**
 * Provides arrows.
 */
- (nonnull NSArray<YMKArrow *> *)arrows;

/**
 * Adds a tap listener for arrows.
 */
- (void)addArrowTapListenerWithTapListener:(nonnull id<YMKArrowTapListener>)tapListener;

/**
 * Removes the tap listener for arrows.
 */
- (void)removeArrowTapListenerWithTapListener:(nonnull id<YMKArrowTapListener>)tapListener;

@end
