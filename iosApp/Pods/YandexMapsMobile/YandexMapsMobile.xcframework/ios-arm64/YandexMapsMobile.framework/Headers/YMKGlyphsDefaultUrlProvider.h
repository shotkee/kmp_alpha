#import <YandexMapsMobile/YMKGlyphsGlyphUrlProvider.h>

#import <YandexMapsMobile/YRTExport.h>

/// :nodoc:
YRT_EXPORT @interface YMKGlyphsDefaultUrlProvider : NSObject<YMKGlyphsGlyphUrlProvider>

- (NSString *)formatUrlWithFontId:(NSString *)fontId
                            range:(YMKGlyphsGlyphIdRange *)range;

- (void)setUrlPattern:(NSString *)urlPattern;

@end
