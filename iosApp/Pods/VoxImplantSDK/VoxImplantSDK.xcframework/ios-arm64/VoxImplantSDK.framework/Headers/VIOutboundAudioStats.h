/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class that represents statistics for outbound <VILocalAudioStream>. Available via <VICallStats>.
 *
 * @namespace call
 */
@interface VIOutboundAudioStats : NSObject

/**
 * The time at which the call statistics are collected, relative to the UNIX epoch (Jan 1, 1970, UTC), in microseconds.
 */
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;
/**
 * Total number of bytes sent within the audio stream.
 */
@property(nonatomic, assign, readonly) NSUInteger bytesSent;
/**
 * Total number of packets sent within the audio stream.
 */
@property(nonatomic, assign, readonly) NSUInteger packetsSent;
/**
 * Audio codec name for the audio stream.
 */
@property(nonatomic, strong, readonly, nullable) NSString *codec;

/**
 * Audio level value is between 0..1 (linear), where 1.0 represents 0 dBov,
 * 0 represents silence, and 0.5 represents approximately 6 dBSPL change in the sound pressure
 * level from 0 dBov.
 */
@property(nonatomic, assign, readonly) double audioLevel;

@end

NS_ASSUME_NONNULL_END
