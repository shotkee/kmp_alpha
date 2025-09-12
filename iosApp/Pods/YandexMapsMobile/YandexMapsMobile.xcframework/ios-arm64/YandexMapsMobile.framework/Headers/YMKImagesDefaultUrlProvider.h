#import <YandexMapsMobile/YMKImagesImageUrlProvider.h>

#import <YandexMapsMobile/YRTExport.h>

/// :nodoc:
YRT_EXPORT @interface YMKImagesDefaultUrlProvider : NSObject<YMKImagesImageUrlProvider>

- (NSString *)formatUrlWithDescriptor:(YMKImagesImageDataDescriptor *)descriptor;

- (void)setUrlBase:(NSString *)urlBase;

@end
