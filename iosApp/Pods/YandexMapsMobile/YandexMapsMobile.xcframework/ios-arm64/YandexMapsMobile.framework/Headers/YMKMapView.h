#import <YandexMapsMobile/YMKMapWindow.h>
#import <YandexMapsMobile/YRTGraphicsApiType.h>
#import <YandexMapsMobile/YRTLifecycleProvider.h>

#import <UIKit/UIKit.h>

#import <YandexMapsMobile/YRTExport.h>

/** Undocumented */
YRT_EXPORT @interface YMKMapView : UIView

@property (nonatomic, readonly) YMKMapWindow *mapWindow;
@property (nonatomic, readonly) BOOL vulkanPreferred;
@property (nonatomic, readonly) float scaleFactor;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)initWithFrame:(CGRect)frame vulkanPreferred:(BOOL)vulkanPreferred;
- (id)initWithFrame:(CGRect)frame scaleFactor:(float)scaleFactor vulkanPreferred:(BOOL)vulkanPreferred;
- (id)initWithFrame:(CGRect)frame
    vulkanPreferred:(BOOL)vulkanPreferred
  lifecycleProvider:(id<YRTLifecycleProvider>)lifecycleProvider;
- (id)initWithFrame:(CGRect)frame
        scaleFactor:(float)scaleFactor
    vulkanPreferred:(BOOL)vulkanPreferred
  lifecycleProvider:(id<YRTLifecycleProvider>)lifecycleProvider;
- (void)setNoninteractive:(bool)is;
- (enum YRTGraphicsAPIType)getGraphicsAPI;

@end
