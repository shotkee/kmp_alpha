#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKPoint.h>
#import <YandexMapsMobile/YRTExport.h>

@class YMKVisibleRegion;

/**
 * Defines the visible region.
 */
YRT_EXPORT @interface YMKVisibleRegion : NSObject

/**
 * Top-left of the visible region.
 */
@property (nonatomic, readonly, nonnull) YMKPoint *topLeft;

/**
 * Top-right of the visible region.
 */
@property (nonatomic, readonly, nonnull) YMKPoint *topRight;

/**
 * Bottom-left of the visible region.
 */
@property (nonatomic, readonly, nonnull) YMKPoint *bottomLeft;

/**
 * Bottom-right of the visible region.
 */
@property (nonatomic, readonly, nonnull) YMKPoint *bottomRight;


+ (nonnull YMKVisibleRegion *)visibleRegionWithTopLeft:(nonnull YMKPoint *)topLeft
                                              topRight:(nonnull YMKPoint *)topRight
                                            bottomLeft:(nonnull YMKPoint *)bottomLeft
                                           bottomRight:(nonnull YMKPoint *)bottomRight;


@end

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKVisibleRegionUtils : NSObject

/**
 * Converts geometry to polygons.
 */
+ (nonnull YMKGeometry *)toPolygonWithVisibleRegion:(nonnull YMKVisibleRegion *)visibleRegion;

@end

