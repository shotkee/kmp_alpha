/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VIVideoStream.h"
@class VIVideoStreamLayerStats;

NS_ASSUME_NONNULL_BEGIN

/**
 * Class that represents statistics for outbound <VILocalVideoStream>. Available via <VICallStats>.
 *
 * @namespace call
 */
@interface VIOutboundVideoStats : NSObject

/**
 * The time at which the call statistics are collected, relative to the UNIX epoch (Jan 1, 1970, UTC), in microseconds.
 */
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;
/**
 * Type of video stream.
 */
@property(nonatomic, assign, readonly) VIVideoStreamType streamType;
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
 * The width of the video frame captured by camera.
 */
@property(nonatomic, assign, readonly) NSUInteger cameraFrameWidth;
/**
 * The height of the video frame captured by camera.
 */
@property(nonatomic, assign, readonly) NSUInteger cameraFrameHeight;
/**
 * The number of complete frames in the last second.
 */
@property(nonatomic, assign, readonly) NSUInteger fps;
/**
 * Video codec name for the video stream.
 */
@property(nonatomic, strong, readonly, nullable) NSString *codec;
/**
 * Target bitrate for video encoder that does not count the size of the IP and other transport
 * layers like TCP or UDP. Measured in bits per second and calculated over a 1 second window.
 */
@property(nonatomic, assign, readonly) double targetBitrate;
/**
 * Bitrate that the encoder is actually producing. Measured in bits per seconds and calculated
 * over a 1 second window.
 */
@property(nonatomic, assign, readonly) double encoderBitrate;
/**
 * Statistics for the layers of the video stream.
 */
@property(nonatomic, strong, readonly) NSArray<VIVideoStreamLayerStats *> *layersStats;

@end

NS_ASSUME_NONNULL_END
