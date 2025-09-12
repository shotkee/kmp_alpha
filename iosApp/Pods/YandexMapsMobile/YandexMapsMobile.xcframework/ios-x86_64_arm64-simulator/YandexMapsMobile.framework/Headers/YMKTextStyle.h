#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

/**
 * Text placement positions
 */
typedef NS_ENUM(NSUInteger, YMKTextStylePlacement) {
    /**
     * Undocumented
     */
    YMKTextStylePlacementCenter,
    /**
     * Undocumented
     */
    YMKTextStylePlacementLeft,
    /**
     * Undocumented
     */
    YMKTextStylePlacementRight,
    /**
     * Undocumented
     */
    YMKTextStylePlacementTop,
    /**
     * Undocumented
     */
    YMKTextStylePlacementBottom,
    /**
     * Undocumented
     */
    YMKTextStylePlacementTopLeft,
    /**
     * Undocumented
     */
    YMKTextStylePlacementTopRight,
    /**
     * Undocumented
     */
    YMKTextStylePlacementBottomLeft,
    /**
     * Undocumented
     */
    YMKTextStylePlacementBottomRight
};

/**
 * The style of placemarks's text.
 */
YRT_EXPORT @interface YMKTextStyle : NSObject

/**
 * Text font size in units. default: 8
 */
@property (nonatomic, assign) float size;

/**
 * Text color. default: black
 *
 * Optional field, can be nil.
 */
@property (nonatomic, strong, nullable) UIColor *color;

/**
 * Outline color. default: white
 *
 * Optional field, can be nil.
 */
@property (nonatomic, strong, nullable) UIColor *outlineColor;

/**
 * Text placement position. default: Center
 */
@property (nonatomic, assign) YMKTextStylePlacement placement;

/**
 * Text offset in units. Measured either from point or form icon edges,
 * depending on offsetFromIcon value Direction of the offset specified
 * with placement property Ignored when placement is 'Center' default: 0
 */
@property (nonatomic, assign) float offset;

/**
 * When set, offset is a padding between the text and icon edges.
 * default: true
 */
@property (nonatomic, assign) BOOL offsetFromIcon;

/**
 * Allow dropping text but keeping icon during conflict resolution
 * default: false
 */
@property (nonatomic, assign) BOOL textOptional;

+ (nonnull YMKTextStyle *)textStyleWithSize:( float)size
                                      color:(nullable UIColor *)color
                               outlineColor:(nullable UIColor *)outlineColor
                                  placement:( YMKTextStylePlacement)placement
                                     offset:( float)offset
                             offsetFromIcon:( BOOL)offsetFromIcon
                               textOptional:( BOOL)textOptional;


- (nonnull YMKTextStyle *)init;

@end
