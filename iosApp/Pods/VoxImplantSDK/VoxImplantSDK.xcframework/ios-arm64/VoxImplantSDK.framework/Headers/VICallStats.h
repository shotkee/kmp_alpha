/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VIEndpointStats;
@class VIOutboundAudioStats;
@class VIOutboundVideoStats;

/**
 * Class that represents statistics for the <VICall>. Reported via <[VICallDelegate call:didReceiveStatistics:]>
 *
 * @namespace call
 */
@interface VICallStats : NSObject

/**
 * The time at which the call statistics are collected, relative to the UNIX epoch (Jan 1, 1970, UTC), in microseconds.
 */
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;

/**
 * The type of network interface used by the base of a local candidate (the address the ICE agent sends from).
 *
 * This stat only tells you about the network interface used by the first "hop";
 * it's possible that a connection will be bottlenecked by another type of network.
 *
 * For example, when using Wi-Fi tethering, the networkType of the relevant candidate would be "wifi",
 * even when the next hop is over a cellular connection.
 *
 * Possible values:
 * - cellular - A cellular connection (e.g., EDGE, HSPA, LTE, etc.).
 * - ethernet - An Ethernet connection.
 * - wifi - A Wi-Fi connection.
 * - wimax - A WiMAX connection.
 * - vpn - The connection runs over a VPN. The underlying network type is not available.
 * - unknown - The user agent is unable or unwilling to identify the underlying connection technology.
 */
@property(nonatomic, strong, readonly) NSString *networkType;

/**
 * The type of the local ICE candidate.
 *
 * Possible values:
 * - host - A host candidate
 * - srflx - A server reflexive candidate
 * - prflx - A peer reflexive candidate
 * - relay - A relay candidate
 */
@property(nonatomic, strong, readonly) NSString *localCandidateType;

/**
 * The type of the remote ICE candidate.
 *
 * Possible values:
 * - host - A host candidate
 * - srflx - A server reflexive candidate
 * - prflx - A peer reflexive candidate
 * - relay - A relay candidate
 */
@property(nonatomic, strong, readonly) NSString *remoteCandidateType;

/**
 * Represents the latest round trip time measured in seconds.
 */
@property(nonatomic, assign, readonly) NSTimeInterval rtt;

/**
 * It is calculated by the underlying congestion control by combining the available bitrate
 * for all the outgoing RTP streams using a current selected candidate pair.
 *
 * It is measured in bits per second and the bitrate is calculated over a 1 second window.
 */
@property(nonatomic, assign, readonly) double availableOutgoingBitrate;

/**
 * Total number of bytes (audio and video) received in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger totalBytesReceived;
/**
 * Total number of bytes (audio and video) sent in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger totalBytesSent;
/**
 * Total number of packets (audio and video) received in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger totalPacketsReceived;
/**
 * Total number of packets (audio and video) sent in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger totalPacketsSent;
/**
 * Total number of incoming packets lost (audio and video) in the call.
 */
@property(nonatomic, assign, readonly) NSUInteger totalPacketsLost;
/**
 * Total incoming packet loss for the call.
 */
@property(nonatomic, assign, readonly) double totalLoss;

/**
 * Total number of audio bytes received for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioBytesReceived;
/**
 * Total number of audio bytes sent for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioBytesSent;
/**
 * Total number of audio packets received for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioPacketsReceived;
/**
 * Total number of audio packets sent for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioPacketsSent;
/**
 * Total number of audio packets lost for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger audioPacketsLost;
/**
 * Total packet loss in the audio stream(s) related to the call session. Values are in the range 0..1, where 0 means no loss and 1 means full loss.
 */
@property(nonatomic, assign, readonly) double audioLoss;

/**
 * Total number of video bytes received for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoBytesReceived;
/**
 * Total number of video bytes sent for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoBytesSent;
/**
 * Total number of video packets received for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoPacketsReceived;
/**
 * Total number of video packets sent for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoPacketsSent;
/**
 * Total number of video packets lost for the call.
 */
@property(nonatomic, assign, readonly) NSUInteger videoPacketsLost;
/**
 * Total packet loss in the video stream(s) related to the call session. Values are in the range 0..1, where 0 means no loss and 1 means full loss.
 */
@property(nonatomic, assign, readonly) double videoLoss;

/**
 * Statistics for endpoints existing in the call at the moment of the stats collection.
 */
@property(nonatomic, strong, readonly) NSDictionary<NSString *, VIEndpointStats *> *endpointStats;
/**
 * Statistics for all active outgoing audio streams of the call at the moment of the stats collection.
 */
@property(nonatomic, strong, readonly) NSDictionary<NSString *, VIOutboundAudioStats *> *localAudioStats;
/**
 * Statistics for all active outgoing video streams of the call at the moment of the stats collection.
 */
@property(nonatomic, strong, readonly) NSDictionary<NSString *, VIOutboundVideoStats *> *localVideoStats;

@end

NS_ASSUME_NONNULL_END
