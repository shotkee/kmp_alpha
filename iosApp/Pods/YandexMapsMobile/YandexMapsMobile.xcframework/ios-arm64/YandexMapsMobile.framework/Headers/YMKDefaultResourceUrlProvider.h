#import <YandexMapsMobile/YMKResourceUrlProvider.h>

#import <YandexMapsMobile/YRTExport.h>

/// :nodoc:
YRT_EXPORT @interface YMKDefaultResourceUrlProvider : NSObject<YMKResourceUrlProvider>

- (NSString *)formatUrlWithResourceId:(NSString *)resId;

- (void)setUrlBase:(NSString *)urlBase;

@end
