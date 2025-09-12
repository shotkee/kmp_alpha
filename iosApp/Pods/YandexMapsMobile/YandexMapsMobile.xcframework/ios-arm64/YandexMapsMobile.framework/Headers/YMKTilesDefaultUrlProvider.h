#import <YandexMapsMobile/YMKTilesUrlProvider.h>
#import <YandexMapsMobile/YMKZoomRange.h>
#import <YandexMapsMobile/YRTExport.h>

/// :nodoc:
YRT_EXPORT @interface YMKTilesDefaultUrlProvider : NSObject<YMKTilesUrlProvider>

- (NSString *)formatUrlWithTileId:(YMKTileId *)tileId
                          version:(YMKVersion *)version;

- (void)setUrlPattern:(NSString *)urlPattern;

- (void)setZoomRanges:(NSArray *)zoomRanges;

@end
