/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VIRTCMacros.h"
#import "VIRTCVideoSource.h"

@class RTC_OBJC_TYPE(RTCPeerConnectionFactory);
@class RTC_OBJC_TYPE(RTCMediaConstraints);

// right now only NV12 supported

RTC_EXTERN uint32_t kFOURCC_I420;

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE(RTCVideoFormat) : NSObject

@property(nonatomic, assign, readonly) NSUInteger width;
@property(nonatomic, assign, readonly) NSUInteger height;
@property(nonatomic, assign, readonly) NSUInteger interval; // Nanoseconds = 1/FPS
@property(nonatomic, assign, readonly) uint32_t fourcc; // Nanoseconds = 1/FPS

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height interval:(NSUInteger)interval fourcc:(uint32_t)fourcc;

- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height fps:(NSUInteger)fps fourcc:(uint32_t)fourcc;

@end

RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE(RTCCustomVideoSourceDelegate) <NSObject>

- (void)startWithVideoFormat:(RTC_OBJC_TYPE(RTCVideoFormat) *)videoFormat;

- (void)stop;

@end

@class RTC_OBJC_TYPE(RTCVideoFrame);

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE(RTCCustomVideoSource) : RTC_OBJC_TYPE(RTCVideoSource)

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFactory:(RTC_OBJC_TYPE(RTCPeerConnectionFactory) *)factory
                    constraints:(RTC_OBJC_TYPE(RTCMediaConstraints) *)constraints
               supportedFormats:(NSArray<RTC_OBJC_TYPE(RTCVideoFormat) *> *)supportedFormats
                       delegate:(id <RTC_OBJC_TYPE(RTCCustomVideoSourceDelegate)>)delegate
                   isScreenCast:(BOOL)isScreenCast;

- (void)sendVideoFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)videoFrame;

@end
