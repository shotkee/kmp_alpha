/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class that represents statistics for outbound <VILocalVideoStream> layers. Available via <VIOutboundVideoStats>.
 *
 * @namespace call
 */
@interface VIVideoStreamLayerStats : NSObject

/**
 * The idenfifier of the encoding layer.
 *
 * nil if simulcast is disabled.
 */
@property(nonatomic, assign, readonly, nullable) NSString *rid;
/**
 * Total number of bytes sent within the video stream.
 */
@property(nonatomic, assign, readonly) NSUInteger bytesSent;
/**
 * Total number of bytes sent in the last second.
 */
@property(nonatomic, assign, readonly) NSUInteger bytesPerSecond;
/**
 * Total number of packets sent within the video stream.
 */
@property(nonatomic, assign, readonly) NSUInteger packetsSent;
/**
 * Video frame width sent within the video stream at the moment the statistics are collected.
 */
@property(nonatomic, assign, readonly) NSUInteger frameWidth;
/**
 * Video frame height sent within the video stream at the moment the statistics are collected.
 */
@property(nonatomic, assign, readonly) NSUInteger frameHeight;
/**
 * The number of complete frames in the last second
 */
@property(nonatomic, assign, readonly) NSUInteger fps;

@end

NS_ASSUME_NONNULL_END
