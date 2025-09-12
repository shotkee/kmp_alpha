#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Universal key-value data.
 */
YRT_EXPORT @interface YRTKeyValuePair : NSObject

/**
 * Data key. For example, "currency".
 */
@property (nonatomic, readonly, nonnull) NSString *key;

/**
 * Data value. For example, "USD".
 */
@property (nonatomic, readonly, nonnull) NSString *value;


+ (nonnull YRTKeyValuePair *)keyValuePairWithKey:(nonnull NSString *)key
                                           value:(nonnull NSString *)value;


@end
