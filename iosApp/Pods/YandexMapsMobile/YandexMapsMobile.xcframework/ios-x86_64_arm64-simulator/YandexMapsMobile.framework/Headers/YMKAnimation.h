#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Available animation types.
 */
typedef NS_ENUM(NSUInteger, YMKAnimationType) {
    /**
     * Smooth interpolation between start and finish states.
     */
    YMKAnimationTypeSmooth,
    /**
     * Movement with constant speed during animation time.
     */
    YMKAnimationTypeLinear
};

/**
 * The animation that is used to switch between states.
 */
YRT_EXPORT @interface YMKAnimation : NSObject

/**
 * Animation type.
 */
@property (nonatomic, readonly) YMKAnimationType type;

/**
 * Animation duration, in seconds.
 */
@property (nonatomic, readonly) float duration;


+ (nonnull YMKAnimation *)animationWithType:( YMKAnimationType)type
                                   duration:( float)duration;


@end
