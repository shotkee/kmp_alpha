#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YandexMapsMobile/YRTExport.h>

/** Undocumented */
YRT_EXPORT @interface YRTAnimatedImage : NSObject

- (id)initWithLoopCount:(int)loopCount;
- (id)initWithLoopCount:(int)loopCount frames:(NSArray*)frames;
- (void)addFrameWithImage:(UIImage*)image duration:(NSTimeInterval)duration;
- (int)loopCount;
- (NSArray*)frames;

@end
