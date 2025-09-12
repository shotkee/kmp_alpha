#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

@class YMKAttributionAuthor;
@class YMKAttributionLink;

/**
 * Details about the source of information.
 */
YRT_EXPORT @interface YMKAttribution : NSObject

/**
 * Additional information about the author.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) YMKAttributionAuthor *author;

/**
 * Link to a specific page on the author's site. To link to the website
 * as a whole, use author.uri.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) YMKAttributionLink *link;


+ (nonnull YMKAttribution *)attributionWithAuthor:(nullable YMKAttributionAuthor *)author
                                             link:(nullable YMKAttributionLink *)link;


@end

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKAttributionAuthor : NSObject

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSString *name;

/**
 * A reference to the author's site.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) NSString *uri;

/**
 * Author's email. Must contain at least one @ symbol.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) NSString *email;


+ (nonnull YMKAttributionAuthor *)authorWithName:(nonnull NSString *)name
                                             uri:(nullable NSString *)uri
                                           email:(nullable NSString *)email;


@end

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKAttributionLink : NSObject

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSString *href;


+ (nonnull YMKAttributionLink *)linkWithHref:(nonnull NSString *)href;


@end
