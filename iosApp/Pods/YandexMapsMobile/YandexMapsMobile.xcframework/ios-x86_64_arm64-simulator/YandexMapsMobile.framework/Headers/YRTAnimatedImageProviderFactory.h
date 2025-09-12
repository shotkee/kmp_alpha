#import <Foundation/Foundation.h>
#import <YandexMapsMobile/YRTAnimatedImage.h>
#import <YandexMapsMobile/YRTExport.h>

/** Undocumented */
YRT_EXPORT @interface YRTAnimatedImageProviderFactory : NSObject

+ (id)fromFile:(NSString*)path;
+ (id)fromData:(NSData*)data;
+ (id)fromAnimatedImage:(YRTAnimatedImage*)animatedImage;

@end
