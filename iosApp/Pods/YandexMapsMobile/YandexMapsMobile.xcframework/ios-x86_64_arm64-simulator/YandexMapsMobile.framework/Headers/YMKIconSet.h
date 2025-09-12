#import <YandexMapsMobile/YRTAnimatedImageProvider.h>
#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

/**
 * A set of icons, which can be used in custom geojson layers
 */
YRT_EXPORT @interface YMKIconSet : NSObject

/**
 * Adds the image to the icon set. The image provider's ID will be used
 * as the icon ID. The image size is scaled using the formula "value =
 * scaleFactor / 4". The same ID should be used in geojson tiles.
 */
- (void)addWithImage:(nonnull UIImage *)image;

/**
 * Adds the image with the given ID to the icon source. The image size
 * is scaled using the formula "value = scaleFactor / 4". The same ID
 * should be used in geojson tiles.
 */
- (void)addWithId:(nonnull NSString *)id
            image:(nonnull UIImage *)image;

/**
 * Adds the animated image to the icon set. The image provider's ID will
 * be used as the icon ID. The image size is scaled using the formula
 * "value = scaleFactor / 4". The same ID should be used in geojson
 * tiles.
 */
- (void)addWithAnimatedImage:(nonnull id<YRTAnimatedImageProvider>)image;

/**
 * Adds the animated image with the given ID to the icon source. The
 * image size is scaled using the formula "value = scaleFactor / 4". The
 * same ID should be used in geojson tiles.
 */
- (void)addWithId:(nonnull NSString *)id
    animatedImage:(nonnull id<YRTAnimatedImageProvider>)image;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
