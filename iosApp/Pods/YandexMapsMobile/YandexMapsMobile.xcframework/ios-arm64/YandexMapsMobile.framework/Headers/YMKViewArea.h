#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Defines the visible area.
 */
YRT_EXPORT @interface YMKViewArea : NSObject

/**
 * The length of the view area in meters.
 */
@property (nonatomic, readonly) double lengthwise;

/**
 * The width of the view area from center in meters.
 */
@property (nonatomic, readonly) double transverse;


+ (nonnull YMKViewArea *)viewAreaWithLengthwise:( double)lengthwise
                                     transverse:( double)transverse;


@end
