/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "VIRTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_EXTERN const int kRTCAudioSessionPreferredNumberOfChannels;
RTC_EXTERN const double kRTCAudioSessionHighPerformanceSampleRate;
RTC_EXTERN const double kRTCAudioSessionLowComplexitySampleRate;
RTC_EXTERN const double kRTCAudioSessionHighPerformanceIOBufferDuration;
RTC_EXTERN const double kRTCAudioSessionLowComplexityIOBufferDuration;

typedef NS_OPTIONS(NSUInteger, RTCAudioSessionConfigurationOptions)
{
    RTCAudioSessionConfigurationOptionsNothing               = 0,
    // both AVAudioSessionCategory and AVAudioSessionCategoryOption
    RTCAudioSessionConfigurationOptionCategory               = 1 << 0,
    RTCAudioSessionConfigurationOptionMode                   = 1 << 1,
    RTCAudioSessionConfigurationOptionSampleRate             = 1 << 2,
    RTCAudioSessionConfigurationOptionIOBufferDuraton        = 1 << 3,
    RTCAudioSessionConfigurationOptionInputNumberOfChannels  = 1 << 4,
    RTCAudioSessionConfigurationOptionOutputNumberOfChannels = 1 << 5,
    RTCAudioSessionConfigurationOptionPortOverride           = 1 << 6,
    RTCAudioSessionConfigurationOptionPreferredInput         = 1 << 7,
    RTCAudioSessionConfigurationOptionsAll                   = NSUIntegerMax
};

// Struct to hold configuration values.
RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE (RTCAudioSessionConfiguration) : NSObject

/** By default all options are required to apply. Sign which options would be skipped. */
@property(nonatomic, assign) RTCAudioSessionConfigurationOptions requiredOptions;

@property(nonatomic, strong) NSString *category;
@property(nonatomic, assign) AVAudioSessionCategoryOptions categoryOptions;
@property(nonatomic, strong) NSString *mode;
@property(nonatomic, assign) double sampleRate;
@property(nonatomic, assign) NSTimeInterval ioBufferDuration;
@property(nonatomic, assign) NSInteger inputNumberOfChannels;
@property(nonatomic, assign) NSInteger outputNumberOfChannels;
@property(nonatomic, assign) AVAudioSessionPortOverride portOverride;
@property(nonatomic, strong, nullable) AVAudioSessionPortDescription *preferredInput;

/** Initializes configuration to defaults. */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/** Returns the current configuration of the audio session. */
+ (instancetype)currentConfiguration;
/** Returns the configuration that WebRTC needs. */
+ (instancetype)webRTCConfiguration;
/** Provide a way to override the default configuration. */
+ (void)setWebRTCConfiguration:(RTC_OBJC_TYPE(RTCAudioSessionConfiguration) *)configuration;

@end

NS_ASSUME_NONNULL_END
