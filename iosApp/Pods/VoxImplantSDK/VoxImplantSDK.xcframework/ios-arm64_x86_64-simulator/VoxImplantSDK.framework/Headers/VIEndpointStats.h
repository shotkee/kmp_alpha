/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VIInboundAudioStats;
@class VIInboundVideoStats;

/**
 * Class that represents <VIEndpoint> statistics
 *
 * @namespace call
 */
@interface VIEndpointStats : NSObject

/**
 * The time at which the call statistics are collected, relative to the UNIX epoch (Jan 1, 1970, UTC), in microseconds.
 */
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;
/**
 * Total number of bytes (audio and video) received from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger totalBytesReceived;
/**
 * Total number of packets (audio and video) received from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger totalPacketsReceived;

/**
 * Total number of audio bytes received from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioBytesReceived;
/**
 * Total number of audio packets received from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioPacketsReceived;
/**
 * Total number of audio packets lost from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioPacketsLost;

/**
 * Total number of video bytes received from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoBytesReceived;
/**
 * Total number of video packets received from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoPacketsReceived;
/**
 * Total number of video packets lost from the endpoint in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoPacketsLost;

/**
 * Statistics for all active incoming video streams from the <VIEndpoint> at the moment of the stats collection.
 */
@property(nonatomic, strong, readonly) NSDictionary<NSString *, VIInboundAudioStats *> *remoteAudioStats;
/**
 * Statistics for all active incoming audio streams from the <VIEndpoint> at the moment of the stats collection.
 */
@property(nonatomic, strong, readonly) NSDictionary<NSString *, VIInboundVideoStats *> *remoteVideoStats;

@end

NS_ASSUME_NONNULL_END
