/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class that represents statistics for inbound <VIRemoteVideoStream>. Available in <VIEndpointStats>.
 *
 * @namespace call
 */
@interface VIInboundVideoStats : NSObject

/**
 * The time at which the call statistics are collected, relative to the UNIX epoch (Jan 1, 1970, UTC), in microseconds.
 */
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;
/**
 * Total number of bytes received within the video stream.
 */
@property(nonatomic, assign, readonly) NSUInteger bytesReceived;
/**
 * Total number of packets received within the video stream.
 */
@property(nonatomic, assign, readonly) NSUInteger packetsReceived;
/**
 * Total number of video packets lost for the video stream.
 */
@property(nonatomic, assign, readonly) NSUInteger packetsLost;
/**
 * Packet loss in the video stream. Values are in the range 0..1, where 0 means no loss and 1 means full loss.
 */
@property(nonatomic, assign, readonly) double loss;
/**
 * The number of complete frames in the last second
 */
@property(nonatomic, assign, readonly) NSUInteger fps;
/**
 * Video frame width received within the video stream at the moment the statistics are collected.
 */
@property(nonatomic, assign, readonly) NSUInteger frameWidth;
/**
 * Video frame height received within the video stream at the moment the statistics are collected.
 */
@property(nonatomic, assign, readonly) NSUInteger frameHeight;
/**
 * Video codec name for the video stream, e.g. "VP8".
 */
@property(nonatomic, strong, readonly, nullable) NSString *codec;

/**
 *  Temporary storage buffer used to capture incoming data packets.
 *
 *  It is used to ensure the continuity of streams by smoothing out packet arrival times during
 *  periods of network congestion.
 *
 *  Measured in milliseconds.
 */
@property(nonatomic, assign, readonly) NSTimeInterval jitterBufferMs;

@end

NS_ASSUME_NONNULL_END
