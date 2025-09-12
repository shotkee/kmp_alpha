#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

@class YMKProjection;

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKProjections : NSObject

+ (nonnull YMKProjection *)wgs84Mercator;

+ (nonnull YMKProjection *)sphericalMercator;

@end

