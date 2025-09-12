#import <Foundation/Foundation.h>
#import <YandexMapsMobile/YRTModelProvider.h>
#import <YandexMapsMobile/YRTExport.h>

/** Undocumented */
YRT_EXPORT @interface YRTAnimatedModel : NSObject

- (id)initWithLoopCount:(int)loopCount;
- (id)initWithLoopCount:(int)loopCount frames:(NSArray*)frames;
- (void)addFrameWithModel:(id<YRTModelProvider>)model duration:(NSTimeInterval)duration;
- (int)loopCount;
- (NSArray*)frames;

@end
