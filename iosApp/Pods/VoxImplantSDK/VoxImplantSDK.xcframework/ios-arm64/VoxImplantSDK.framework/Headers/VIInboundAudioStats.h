/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class that represents statistics for inbound <VIRemoteAudioStream>. Available in <VIEndpointStats>.
 *
 * @namespace call
 */
@interface VIInboundAudioStats : NSObject

/**
 * The time at which the call statistics are collected, relative to the UNIX epoch (Jan 1, 1970, UTC), in microseconds.
 */
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;
/**
 * Total number of bytes received within the audio stream.
 */
@property (nonatomic, assign, readonly) NSUInteger bytesReceived;
/**
 * Total number of packets received within the audio stream.
 */
@property (nonatomic, assign, readonly) NSUInteger packetsReceived;
/**
 * Total number of audio packets lost for the audio stream.
 */
@property (nonatomic, assign, readonly) NSUInteger packetsLost;
/**
 * Audio codec name for the audio stream, e.g. "opus".
 */
@property (nonatomic, strong, readonly, nullable) NSString *codec;
/**
 * Packet loss in the audio stream. Values are in the range 0..1, where 0 means no loss and 1 means full loss.
 */
@property (nonatomic, assign, readonly) double loss;

/**
 *  Temporary storage buffer used to capture incoming data packets.
 *
 *  It is used to ensure the continuity of streams by smoothing out packet arrival times during
 *  periods of network congestion.
 *
 *  Measured in milliseconds.
 */
@property (nonatomic, assign, readonly) NSTimeInterval jitterBufferMs;

/**
 * Audio level value is between 0..1 (linear), where 1.0 represents 0 dBov,
 * 0 represents silence, and 0.5 represents approximately 6 dBSPL change in the sound pressure
 * level from 0 dBov.
 */
@property (nonatomic, assign, readonly) double audioLevel;

@end

NS_ASSUME_NONNULL_END
