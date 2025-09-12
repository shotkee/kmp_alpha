#import <Foundation/Foundation.h>
#import <YandexMapsMobile/YRTAnimatedModel.h>
#import <YandexMapsMobile/YRTAnimatedModelProvider.h>
#import <YandexMapsMobile/YRTExport.h>

/** Undocumented */
YRT_EXPORT @interface YRTAnimatedModelProviderFactory : NSObject

+ (id<YRTAnimatedModelProvider>)fromAnimatedModel:(YRTAnimatedModel*)animatedModel;

@end
