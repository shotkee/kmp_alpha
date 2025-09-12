#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKPoint.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Undocumented
 */
typedef NS_ENUM(NSUInteger, YMKPolylineIndexPriority) {
    /**
     * Undocumented
     */
    YMKPolylineIndexPriorityClosestToRawPoint,
    /**
     * Undocumented
     */
    YMKPolylineIndexPriorityClosestToStart
};

/**
 * Provides methods for binding locations to a polyline
 */
YRT_EXPORT @interface YMKPolylineIndex : NSObject

/**
 * Finds closest polyline position. Returns null if there is no position
 * that satisfies the condition distance(point, position) <
 * maxLocationBias.
 *
 * Two modes are available: 1. Find the closest polyline position to a
 * raw point (Priority::ClosestToRawPoint) 2. Find the closest polyline
 * position to the polyline start (Priority::ClosestToStart).
 */
- (nullable YMKPolylinePosition *)closestPolylinePositionWithPoint:(nonnull YMKPoint *)point
                                                          priority:(YMKPolylineIndexPriority)priority
                                                   maxLocationBias:(double)maxLocationBias;

/**
 * Finds the closest polyline position between the two positions.
 * Returns null if there is no position that satisfies the condition
 * distance(point, position) < maxLocationBias.
 */
- (nullable YMKPolylinePosition *)closestPolylinePositionWithPoint:(nonnull YMKPoint *)point
                                                      positionFrom:(nonnull YMKPolylinePosition *)positionFrom
                                                        positionTo:(nonnull YMKPolylinePosition *)positionTo
                                                   maxLocationBias:(double)maxLocationBias;

@end
