#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

/**
 * The rectangle to display on the map.
 */
YRT_EXPORT @interface YMKRect : NSObject

/**
 * Minimum rectangle coordinates.
 */
@property (nonatomic, readonly) CGPoint min;

/**
 * Maximum rectangle coordinates.
 */
@property (nonatomic, readonly) CGPoint max;


+ (nonnull YMKRect *)rectWithMin:( CGPoint)min
                             max:( CGPoint)max;


@end
