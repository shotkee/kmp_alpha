#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Geo object tags.
 */
YRT_EXPORT @interface YMKGeoObjectTags : NSObject

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSArray<NSString *> *tags;


+ (nonnull YMKGeoObjectTags *)geoObjectTagsWithTags:(nonnull NSArray<NSString *> *)tags;


@end
