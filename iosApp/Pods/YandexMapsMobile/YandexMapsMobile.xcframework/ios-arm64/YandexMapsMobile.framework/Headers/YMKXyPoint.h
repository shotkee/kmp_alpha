#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * World coordinates.
 */
YRT_EXPORT @interface YMKXYPoint : NSObject

/**
 * The horizontal position of the point.
 */
@property (nonatomic, readonly) double x;

/**
 * The vertical position of the point.
 */
@property (nonatomic, readonly) double y;


+ (nonnull YMKXYPoint *)xYPointWithX:( double)x
                                   y:( double)y;


@end
