#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Describes data attached to features in user layer.
 */
YRT_EXPORT @interface YMKUserData : NSObject

/**
 * A dictionary of data.
 */
@property (nonatomic, readonly, nonnull) NSDictionary<NSString *, NSString *> *data;


+ (nonnull YMKUserData *)userDataWithData:(nonnull NSDictionary<NSString *, NSString *> *)data;


@end
