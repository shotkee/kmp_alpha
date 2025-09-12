#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol YRTModelProvider

- (NSString*)modelId;
- (NSData*)model;
- (UIImage*)texture;

@end
