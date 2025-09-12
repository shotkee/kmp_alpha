#import <Foundation/Foundation.h>
#import <YandexMapsMobile/YRTAnimatedModel.h>

@protocol YRTAnimatedModelProvider

- (NSString*)modelId;
- (YRTAnimatedModel*)model;

@end
