#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Undocumented
 */
typedef NS_ENUM(NSUInteger, YMKModelParamsCSOrientation) {
    /**
     * x goes left, z goes down within the plane, y goes up from the plane
     */
    YMKModelParamsCSOrientationRightHanded,
    /**
     * x goes left, z goes up within the plane, y goes up from the plane
     */
    YMKModelParamsCSOrientationLeftHanded
};

/**
 * Params that are used for creating model
 */
YRT_EXPORT @interface YMKModelParams : NSObject

/**
 * Coordinate system orientation
 */
@property (nonatomic, assign) YMKModelParamsCSOrientation csOrientation;

+ (nonnull YMKModelParams *)modelParamsWithCsOrientation:( YMKModelParamsCSOrientation)csOrientation;


- (nonnull YMKModelParams *)init;

@end
