/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VIVideoFlags.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @namespace call
 */
typedef NS_ENUM(NSInteger, VIVideoCodec) {
    /** Video codec for call will be chosen automatically */
            VIVideoCodecAuto = 0,
    /** Call will try to use VP8 video codec */
            VIVideoCodecVP8 = 1,
    /** Call will try to use H264 video codec */
            VIVideoCodecH264 = 2,
};

/**
 * Call settings with additional call parameters, such as preferred video codec, custom data, extra headers etc.
 *
 * @namespace call
 */
@interface VICallSettings : NSObject

/**
 * A custom string associated with the call session.
 *
 * It can be passed to the cloud to be obtained from the [CallAlerting](/docs/references/voxengine/appevents#callalerting)
 * event or [Call History](/docs/references/httpapi/managing_history#getcallhistory) using HTTP API.
 *
 * Maximum size is 200 bytes. Use the <[VICall sendMessage:]> method to pass a string over the limit;
 * in order to pass a large data use [media_session_access_url](/docs/references/httpapi/managing_scenarios#startscenarios)
 * on your backend.
 */
@property(nonatomic, strong, nullable) NSString *customData;

/**
 * An optional set of headers to be sent to the Voximplant cloud. Names must begin with "X-" to be processed by SDK.
 */
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *extraHeaders;

/**
 * Specify video settings (send and receive) for the new call. Video is enabled by default.
 */
@property(nonatomic, strong) VIVideoFlags *videoFlags;

/**
 * Specify if simulcast feature should be enabled in the conference call.
 *
 * NO by default.
 *
 * Valid only for conference calls.
 */
@property(nonatomic, assign) BOOL enableSimulcast;

/**
 * A preferred video codec for a particular call that this VICallSettings are applied to.
 * <VIVideoCodecAuto> by default.
 */
@property(nonatomic, assign) VIVideoCodec preferredVideoCodec;

/**
 * Specify if audio can be received within the call. Default value - YES.
 */
@property(nonatomic, assign) BOOL receiveAudio;

/**
 * Call statistics collection interval in milliseconds. 
 * 
 * Default value - 5000.
 *
 * Interval value should be multiple of 500, otherwise the provided value is rounded to a less value that is multiple of 500.
 */
@property(nonatomic, assign) NSUInteger statsCollectionInterval;

@end

NS_ASSUME_NONNULL_END
