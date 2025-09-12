#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * URI that can be used for requests.
 */
YRT_EXPORT @interface YMKUri : NSObject

/**
 * Gets URI.
 */
@property (nonatomic, readonly, nonnull) NSString *value;


+ (nonnull YMKUri *)uriWithValue:(nonnull NSString *)value;


@end

/**
 * URI metadata.
 */
YRT_EXPORT @interface YMKUriObjectMetadata : NSObject

/**
 * Gets a list of URIs.
 */
@property (nonatomic, readonly, nonnull) NSArray<YMKUri *> *uris;


+ (nonnull YMKUriObjectMetadata *)uriObjectMetadataWithUris:(nonnull NSArray<YMKUri *> *)uris;


@end
