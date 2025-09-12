/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "VIRTCVideoFrame.h"

#import "VIRTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^VideoPreProcessBlock)(CVPixelBufferRef pixel_buffer, RTCVideoRotation rotation);
typedef NS_OPTIONS(NSInteger, SupportedDeviceOrientation) {
    SupportedDeviceOrientationPortrait = 1 << 0,
    SupportedDeviceOrientationPortraitUpsideDown = 1 << 1,
    SupportedDeviceOrientationLandscapeLeft = 1 << 2,
    SupportedDeviceOrientationLandscapeRight = 1 << 3,
    SupportedDeviceOrientationAll = SupportedDeviceOrientationPortrait | SupportedDeviceOrientationPortraitUpsideDown | SupportedDeviceOrientationLandscapeLeft | SupportedDeviceOrientationLandscapeRight,
};

@class RTC_OBJC_TYPE(RTCVideoCapturer);

RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE
(RTCVideoCapturerDelegate)<NSObject> -
    (void)capturer : (RTC_OBJC_TYPE(RTCVideoCapturer) *)capturer didCaptureVideoFrame
    : (RTC_OBJC_TYPE(RTCVideoFrame) *)frame;
@end

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE (RTCVideoCapturer) : NSObject

@property(nonatomic, weak) id<RTC_OBJC_TYPE(RTCVideoCapturerDelegate)> delegate;

- (instancetype)initWithDelegate:(id<RTC_OBJC_TYPE(RTCVideoCapturerDelegate)>)delegate;

@end

NS_ASSUME_NONNULL_END
