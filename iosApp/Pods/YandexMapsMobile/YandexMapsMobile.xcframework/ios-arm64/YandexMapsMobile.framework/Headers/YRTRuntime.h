#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * :nodoc:
 */
YRT_EXPORT @interface YRTRuntime : NSObject

/**
 * Undocumented
 */
+ (nonnull NSString *)version;

/**
 * Undocumented
 */
+ (void)setPreinitializationOptions:(nonnull NSDictionary<NSString *, NSString *> *)runtimeOptions;

@end

