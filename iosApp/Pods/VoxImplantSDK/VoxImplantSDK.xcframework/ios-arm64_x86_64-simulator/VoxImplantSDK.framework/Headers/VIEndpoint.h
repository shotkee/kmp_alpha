/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class VIEndpoint;
@class VIRemoteAudioStream;
@class VIRemoteVideoStream;
@class VICall;
@class VIEndpointStat;

NS_ASSUME_NONNULL_BEGIN

/**
 * Enum that represents the reason why video receive on the remote video stream was stopped.
 *
 * @namespace call
 */
typedef NSString *VIVideoStreamReceiveStopReason NS_STRING_ENUM;
/**
 * Indicates that video receive on a remote video stream is stopped by the Voximplant Cloud due to a network issue on the device.
 */
FOUNDATION_EXPORT VIVideoStreamReceiveStopReason const VIVideoStreamReceiveStopReasonAutomatic;
/**
 * Indicates that video receive on a remote video stream is stopped by the client via <[VIRemoteVideoStream stopReceiving]> API.
 */
FOUNDATION_EXPORT VIVideoStreamReceiveStopReason const VIVideoStreamReceiveStopReasonManual;

/**
 * Delegate that may be used to handle endpoint events.
 *
 * @namespace call
 */
@protocol VIEndpointDelegate <NSObject>

@optional

/**
 * Triggered after endpoint added video stream to the call.
 *
 * Triggered always on the main thread, even if delegateQueue (set in <[VIClient initWithDelegateQueue:]>) is not the main thread.
 *
 * @param endpoint    The endpoint that triggered this event.
 * @param videoStream  The remote video stream added to the call.
 */
- (void)endpoint:(VIEndpoint *)endpoint didAddRemoteVideoStream:(VIRemoteVideoStream *)videoStream
NS_SWIFT_NAME(endpoint(_:didAddRemoteVideoStream:));

/**
 * Triggered after endpoint removed video stream from the call.
 *
 * Triggered always on the main thread, even if delegateQueue (set in <[VIClient initWithDelegateQueue:]>) is not the main thread.
 *
 * @param endpoint    Endpoint that triggered this event.
 * @param videoStream Remote video stream removed from the call.
 */
- (void)endpoint:(VIEndpoint *)endpoint didRemoveRemoteVideoStream:(VIRemoteVideoStream *)videoStream
NS_SWIFT_NAME(endpoint(_:didRemoveRemoteVideoStream:));

/**
 * Triggered when video receive on a remote video stream is started after previously being stopped. Available only for the conference calls.
 *
 * The event is triggered if:
 * 1. <[VIRemoteVideoStream startReceiving]> was called and the request has been processed successfully.
 * 2. A network issue that caused the Voximplant Cloud to stop video receive of the remote video stream is gone.
 *
 * The event is not triggered if the endpoint client has started sending video using <[VICall setSendVideo:completion:]> API.
 *
 * @param endpoint The endpoint that triggered this event.
 * @param videoStream The remote video stream where video receive is started
 */
- (void)endpoint:(VIEndpoint *)endpoint didStartReceivingVideoStream:(VIRemoteVideoStream *)videoStream
NS_SWIFT_NAME(endpoint(_:didStartReceivingVideoStream:));

/**
 * Triggered when video receive on a remote video stream is stopped. Available only for the conference calls.
 *
 * Video receive on a remote video stream can be stopped due to:
 * 1. <[VIRemoteVideoStream stopReceiving]> was called and the request has been processed successfully. In this case the value of the "reason" parameter is <VIVideoStreamReceiveStopReasonManual>
 * 2. Voximplant Cloud has detected a network issue on the client and automatically stopped the video. In this case the value of the "reason" parameter is <VIVideoStreamReceiveStopReasonAutomatic>
 *
 * If the video receive is disabled automatically, it may be automatically enabled as soon as the network condition on the device is good and there is enough bandwidth to receive the video on this remote video stream.
 * In this case <[VIEndpointDelegate endpoint:didStartReceivingVideoStream:]> event will be invoked.
 *
 * The event is not triggered if the endpoint client has stopped sending video using <[VICall setSendVideo:completion:]> API.
 *
 * @param endpoint The endpoint that triggered this event.
 * @param videoStream The remote video stream where video receive is stopped
 * @param reason The reason for the event, such as video receive is disabled by client or automatically
 */
- (void)endpoint:(VIEndpoint *)endpoint didStopReceivingVideoStream:(VIRemoteVideoStream *)videoStream reason:(VIVideoStreamReceiveStopReason)reason
NS_SWIFT_NAME(endpoint(_:didStopReceivingVideoStream:reason:));

/**
 * Invoked when endpoint information such as display name, user name and sip uri is updated.
 *
 * @param endpoint Endpoint which information is updated.
 */
- (void)endpointInfoDidUpdate:(VIEndpoint *)endpoint;

/**
 * Invoked after the endpoint is removed from a call. Event is not triggered on call end.
 *
 * @param endpoint The endpoint that has been removed from the a call
 */
- (void)endpointDidRemove:(VIEndpoint *)endpoint;

/**
 * Invoked when a voice activity of the endpoint is detected in a conference call.
 *
 * @param endpoint    The endpoint that triggered this event.
 */
- (void)didDetectVoiceActivityStart:(VIEndpoint *)endpoint;

/**
 * Invoked when a voice activity of the endpoint is stopped in a conference call.
 *
 * @param endpoint    The endpoint that triggered this event.
 */
- (void)didDetectVoiceActivityStop:(VIEndpoint *)endpoint;

@end

/**
 * VIEndpoint
 *
 * @namespace call
 */
@interface VIEndpoint : NSObject

/**
 * A delegate to handle the endpoint events.
 */
@property(nonatomic, weak, nullable) id <VIEndpointDelegate> delegate;


/**
 * The call associated with the endpoint.
 */
@property(nonatomic, weak, nullable, readonly) VICall *call;

/**
 * The active audio streams associated with the endpoint
 */
@property(nonatomic, strong, readonly) NSArray<VIRemoteAudioStream *> *remoteAudioStreams;

/**
 * The active video streams associated with the endpoint.
 */
@property(nonatomic, strong, readonly) NSArray<VIRemoteVideoStream *> *remoteVideoStreams;

/**
 * The endpoint id.
 */
@property(nonatomic, strong, readonly) NSString *endpointId;

/**
 * A user name of the endpoint.
 */
@property(nonatomic, strong, readonly, nullable) NSString *user;

/**
 * The SIP URI of the endpoint.
 */
@property(nonatomic, strong, readonly, nullable) NSString *sipURI;

/**
 * A user display name of the endpoint.
 */
@property(nonatomic, strong, readonly, nullable) NSString *userDisplayName;

/**
 * Place of this endpoint in a video conference.
 *
 * May be used as a position of this endpoint's video stream to render in a video conference call.
 *
 * Nil for audio and video calls.
 */
@property(nonatomic, strong, readonly, nullable) NSNumber *place;

@end

NS_ASSUME_NONNULL_END
