#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKImagesImageDataDescriptor : NSObject

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSString *imageId;

/**
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) UIColor *primaryColor;

/**
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) UIColor *secondaryColor;

/**
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) UIColor *tertiaryColor;


+ (nonnull YMKImagesImageDataDescriptor *)imageDataDescriptorWithImageId:(nonnull NSString *)imageId
                                                            primaryColor:(nullable UIColor *)primaryColor
                                                          secondaryColor:(nullable UIColor *)secondaryColor
                                                           tertiaryColor:(nullable UIColor *)tertiaryColor;


@end
