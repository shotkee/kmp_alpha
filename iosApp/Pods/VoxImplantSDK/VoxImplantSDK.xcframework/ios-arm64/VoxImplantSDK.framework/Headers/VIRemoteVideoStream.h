/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIVideoStream.h"
#import "VIClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents remote video streams.
 *
 * Extends <VIVideoStream> which provides functionality to add or remove video renderers.
 *
 * For conference calls it also provides additional functionality to start or stop receiving video from the stream and to request video in another size.
 *
 * @namespace call
 */
@interface VIRemoteVideoStream : VIVideoStream

/**
 * Indicates if the video stream is receiving video.
 *
 * Valid only for conferences.
 */
@property(nonatomic, assign, readonly) BOOL isReceiving;

/**
 * The current frame height of the video stream.
 */
@property(nonatomic, assign, readonly) NSUInteger height;

/**
 * The current frame width of the video stream.
 */
@property(nonatomic, assign, readonly) NSUInteger width;

/**
 * Starts receiving video on the remote video stream. Available only for the conference calls.
 *
 * If the video is already receiving, this method call is ignored.
 *
 * If the request is processed successfully, <[VIEndpointDelegate endpoint:didStartReceivingVideoStream:]> event will be invoked.
 */
- (void)startReceiving;

/**
 * Stops receiving video on the remote video stream. Available only for the conference calls.
 *
 * If the request is processed successfully, <[VIEndpointDelegate endpoint:didStopReceivingVideoStream:reason:]> event will be invoked with the reason <VIVideoStreamReceiveStopReasonManual>
 */
- (void)stopReceiving;

/**
 * Requests the specified video size for the video stream.
 *
 * The stream resolution may be changed to the closest to the specified width and height.
 *
 * Valid only for conferences.
 *
 * @param width Requested width of the video stream
 * @param height Requested height of the video stream
 */
- (void)requestVideoSizeWithWidth:(NSUInteger)width height:(NSUInteger)height
NS_SWIFT_NAME(requestVideoSize(width:height:));

@end

NS_ASSUME_NONNULL_END
