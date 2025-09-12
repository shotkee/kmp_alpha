/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <VoximplantWebRTC/VoximplantWebRTC.h>
#import "VIVideoRenderer.h"
@class VIVideoRendererView;

NS_ASSUME_NONNULL_BEGIN

/**
 * Enum of supported video resize modes.
 *
 * @namespace hardware
 */
typedef NS_ENUM(NSUInteger, VIVideoResizeMode) {
    /** Video frame is scaled to be fit the size of the view by maintaining the aspect ratio (black borders may be displayed). */
            VIVideoResizeModeFit,
    /** Video frame is scaled to fill the size of the view by maintaining the aspect ratio. Some portion of the video frame may be clipped. */
            VIVideoResizeModeFill
};

/**
 * Delegate that may be used to handle call events.
 *
 * @namespace hardware
 */
@protocol VIVideoRendererViewDelegate <NSObject>

@optional

/**
 * Triggered once the first frame is rendered. The event is triggered on the main thread.
 *
 * @param videoView View that triggered the event.
 */
- (void)didRenderFirstFrameOnVideoView:(VIVideoRendererView *)videoView;

/**
 * Triggred once the video frame size is changed.
 *
 * @param videoView View that triggered the event.
 * @param size New video frame size.
 */
- (void)videoView:(VIVideoRendererView *)videoView didChangeVideoSize:(CGSize)size;

@end

/**
 * iOS view that renders remote video or local camera preview video.
 *
 * @namespace hardware
 */
@interface VIVideoRendererView : UIView <VIVideoRenderer>

/**
 * A delegate to handle the renderer view events.
 */
@property(nonatomic, weak, nullable) id<VIVideoRendererViewDelegate> delegate;

/**
 * A resize mode for video renderer.
 */
@property(nonatomic, assign) VIVideoResizeMode resizeMode;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Initialize renderer view instance
 *
 * @param containerView UIView to which video renderer will be added as a subview.
 * @return              Renderer view instance.
 */
- (instancetype)initWithContainerView:(UIView *)containerView;

@end

NS_ASSUME_NONNULL_END
