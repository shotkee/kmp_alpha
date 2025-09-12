/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Types of video stream.
 *
 * @namespace call
 */
typedef NS_ENUM(NSInteger, VIVideoStreamType) {
    /** Indicates that the video stream source is a camera or a custom video source. */
            VIVideoStreamTypeVideo = 1,
    /** Indicates that the video stream source is screen sharing. */
            VIVideoStreamTypeScreenSharing = 2,
};

@protocol VIRTCVideoRenderer;

/**
 * Interface that represents the video streams. It may be used to add or remove  video renderers.
 *
 * @namespace call
 */
@interface VIVideoStream : NSObject

/**
 * The video renderers associated with the stream. UI elements of VIRTCVideoRenderer type are used to display a local preview or a remote video.
 */
@property(nonatomic, strong, readonly) NSSet<id <VIRTCVideoRenderer>> *renderers;

/**
 * The video stream id.
 */
@property(nonatomic, retain, readonly) NSString *streamId;

/**
 * The video stream type.
 */
@property(nonatomic, assign, readonly) VIVideoStreamType type;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Add a new video renderer to the video stream. UI elements of VIRTCVideoRenderer type are used to display a local preview or a remote video.
 *
 * @param renderer New video renderer to be added.
 */
- (void)addRenderer:(id <VIRTCVideoRenderer>)renderer;

/**
 * Remove a previously added video renderer from the video stream. UI elements of VIRTCVideoRenderer type are used to display a local preview or a remote video.
 *
 * @param renderer Previously added video renderer.
 */
- (void)removeRenderer:(id <VIRTCVideoRenderer>)renderer;

/**
 * Remove all video renderers associated with the video stream.
 */
- (void)removeAllRenderers;

@end

NS_ASSUME_NONNULL_END
