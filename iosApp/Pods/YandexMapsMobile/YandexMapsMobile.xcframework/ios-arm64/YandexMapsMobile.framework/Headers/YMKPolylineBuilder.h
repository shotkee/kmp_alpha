#import <Foundation/Foundation.h>
#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKPoint.h>

#import <YandexMapsMobile/YRTExport.h>

/** Undocumented */
YRT_EXPORT @interface YMKPolylineBuilder : NSObject

- (YMKPolylineBuilder *)init;
- (void) appendPolyline:(YMKPolyline *)polyline;
- (void) appendPoint:(YMKPoint *)point;
- (YMKPolyline *)build;

@end
