#import <YandexMapsMobile/YMKSublayerFeatureType.h>
#import <YandexMapsMobile/YRTExport.h>

@class YMKSublayer;

/**
 * Provides interface to change drawing order of the map layers.
 */
YRT_EXPORT @interface YMKSublayerManager : NSObject

/**
 * Finds the first sublayer which belongs to the layer with the
 * specified ID and returns its index. Returns none, if no such sublayer
 * exists.
 */
- (nullable NSNumber *)findFirstOfWithLayerId:(nonnull NSString *)layerId;

/**
 * Finds the first sublayer which belongs to the layer with the
 * specified ID and contains features of the required type, and returns
 * its index. Returns none, if no such sublayer exists.
 */
- (nullable NSNumber *)findFirstOfWithLayerId:(nonnull NSString *)layerId
                                  featureType:(YMKSublayerFeatureType)featureType;

/**
 * Returns size of the list of sublayers.
 */
- (NSUInteger)size;

/**
 * Returns the sublayer with the specified index. Returns none, if no
 * such sublayer exists.
 */
- (nullable YMKSublayer *)getWithSublayerIndex:(NSUInteger)sublayerIndex;

/**
 * Removes the sublayer with the specified index.
 */
- (void)removeWithSublayerIndex:(NSUInteger)sublayerIndex;

/**
 * Moves the sublayer with the specified index to the end of the list.
 */
- (void)moveToEndWithFrom:(NSUInteger)from;

/**
 * Moves the sublayer to the position after sublayer with the specified
 * index.
 */
- (void)moveAfterWithFrom:(NSUInteger)from
                       to:(NSUInteger)to;

/**
 * Moves the sublayer to the position before sublayer with the specified
 * index.
 */
- (void)moveBeforeWithFrom:(NSUInteger)from
                        to:(NSUInteger)to;

/**
 * Creates the new sublayer and appends it to the list.
 */
- (nonnull YMKSublayer *)appendSublayerWithLayerId:(nonnull NSString *)layerId
                                       featureType:(YMKSublayerFeatureType)featureType;

/**
 * Creates the new sublayer and inserts it after sublayer with the
 * specified index.
 */
- (nonnull YMKSublayer *)insertSublayerBeforeWithTo:(NSUInteger)to
                                            layerId:(nonnull NSString *)layerId
                                        featureType:(YMKSublayerFeatureType)featureType;

/**
 * Creates the new sublayer and inserts it before sublayer with the
 * specified index.
 */
- (nonnull YMKSublayer *)insertSublayerAfterWithTo:(NSUInteger)to
                                           layerId:(nonnull NSString *)layerId
                                       featureType:(YMKSublayerFeatureType)featureType;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
