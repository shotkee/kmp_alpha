#import <YandexMapsMobile/YMKSublayerFeatureFilterType.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Provides interface to filter features in a sublayer.
 */
YRT_EXPORT @interface YMKSublayerFeatureFilter : NSObject
/**
 * Describes how the specified class names should be filtered.
 */
@property (nonatomic) YMKSublayerFeatureFilterType type;
/**
 * Collection of tags to filter.
 */
@property (nonatomic, nonnull) NSArray<NSString *> *tags;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
