/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VIClient.h"
#import "VIError.h"
#import "VIQualityIssueDelegate.h"

@class VICall;
@class VILocalVideoStream;
@class VICallStats;
@class VIEndpoint;
@class VICallSettings;
@class VIQualityIssue;

/**
 * Enum of incoming call reject modes.
 *
 * @namespace call
 */
typedef NS_ENUM(NSInteger, VIRejectMode) {
    /** Indicates that user can't answer the call right now, and VoxEngine will terminate the call and any pending calls to other devices of current user. */
            VIRejectModeDecline = 0,
    /** Indicates that the user is not available only at a particular device. */
            VIRejectModeBusy = 1,
};

NS_ASSUME_NONNULL_BEGIN

/**
 * Delegate that may be used to handle call events.
 *
 * @namespace call
 */
@protocol VICallDelegate <NSObject>

@optional

/**
 * Triggered if the call is failed.
 *
 * @param call Call that triggered the event.
 * @param error Error that contains status code and status message of the call failure. See <VICallFailErrorCode> for possible reasons.
 * @param headers Optional headers passed with event.
 */
- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(nullable NSDictionary *)headers;

/**
 * Triggered after call was successfully connected.
 *
 * @param call Call that triggered the event.
 * @param headers Optional headers passed with event.
 */
- (void)call:(VICall *)call didConnectWithHeaders:(nullable NSDictionary *)headers;

/**
 * Triggered after the call was disconnected.
 *
 * @param call Call that triggered the event.
 * @param headers Optional headers passed with event.
 * @param answeredElsewhere YES if call was answered on another device.
 */
- (void)call:(VICall *)call didDisconnectWithHeaders:(nullable NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere;

/**
 * Triggered if the call is ringing. You should start playing call progress tone now.
 *
 * @param call Call that triggered the event.
 * @param headers Optional headers passed with event.
 */
- (void)call:(VICall *)call startRingingWithHeaders:(nullable NSDictionary *)headers;

/**
 * Triggered when audio subsystem is initialized and ready to start audio within the call. You should stop playing progress tone when event is received.
 *
 * @param call Call that triggered the event.
 */
- (void)callDidStartAudio:(VICall *)call;

/**
 * Triggered when message is received within the call. Implemented atop SIP INFO for communication between call endpoint and Voximplant cloud, and is separated from Voximplant messaging API.
 *
 * @param call Call that triggered the event.
 * @param message Content of the message.
 * @param headers Optional headers passed with event.
 */
- (void)call:(VICall *)call didReceiveMessage:(NSString *)message headers:(nullable NSDictionary *)headers;

/**
 * Triggered when INFO message is received within the call.
 *
 * @param call Call that triggered the event.
 * @param body Body of INFO message.
 * @param type MIME type of INFO message.
 * @param headers Optional headers passed with event.
 */
- (void)call:(VICall *)call didReceiveInfo:(NSString *)body type:(NSString *)type headers:(nullable NSDictionary *)headers;

/**
 * Triggered when call statistics are available for the call.
 *
 * @param call Call that triggered the event.
 * @param stat Call statistics.
 */
- (void)call:(VICall *)call didReceiveStatistics:(VICallStats *)stat;

/**
 * Triggered when local video stream is added to the call. The event is triggered on the main thread.
 *
 * @param call Call that triggered the event.
 * @param videoStream Local video stream that is added to the call.
 */
- (void)call:(VICall *)call didAddLocalVideoStream:(VILocalVideoStream *)videoStream
NS_SWIFT_NAME(call(_:didAddLocalVideoStream:));

/**
 * Triggered when local video stream is removed from the call. The event is triggered on the main thread.
 *
 * @param call Call that triggered the event.
 * @param videoStream Local video stream that is removed from the call.
 */
- (void)call:(VICall *)call didRemoveLocalVideoStream:(VILocalVideoStream *)videoStream
NS_SWIFT_NAME(call(_:didRemoveLocalVideoStream:));

/**
 * Invoked after endpoint is added to the call.
 *
 * @param call Call that triggered the event.
 * @param endpoint Added endpoint.
 */
- (void)call:(VICall *)call didAddEndpoint:(VIEndpoint *)endpoint;

/**
 * Triggered when ICE connection is complete.
 *
 * @param call Call that triggered the event.
 */
- (void)iceCompleteForCall:(VICall *)call;

/**
 * Triggered if connection was not established due to network connection problem between 2 peers.
 *
 * @param call Call that triggered the event.
 */
- (void)iceTimeoutForCall:(VICall *)call;

/**
 * Triggered if the connection to the Voximplant Cloud is lost due to a network issue and media streams may be interrupted in the call.
 *
 * Once the connection to the Voximplant Cloud is restored and media streams are active, <[VICallDelegate callDidReconnect:]> event will be invoked.
 *
 * Until <[VICallDelegate callDidReconnect:]> event is invoked, the following API calls will fail with <VICallErrorCodeReconnecting> error:
 * 1. <[VICall setSendVideo:completion:]>
 * 2. <[VICall startReceiveVideoWithCompletion:]>
 * 3. <[VICall setHold:completion:]>
 * 4. <[VICall startInAppScreenSharing:]>
 *
 * Until <[VICallDelegate callDidReconnect:]> event is invoked, the following events will not be invoked:
 * 1. <[VICallDelegate call:didReceiveStatistics:]>
 * 2. any events from <VIQualityIssueDelegate>
 *
 * While the call is reconnecting, all previously detected quality issues (if any) are reset and their <VIQualityIssueLevel> is set to <VIQualityIssueLevelNone>
 *
 * @param call Call that triggered the event.
 */
- (void)callDidStartReconnecting:(VICall *)call;

/**
 * Triggered if the connection to the Voximplant Cloud is restored and media stream are active in the call.
 *
 * @param call Call that triggered the event.
 */
- (void)callDidReconnect:(VICall *)call;

@end

@protocol RTCVideoRenderer;
@class UIView;
@class VIVideoSource;

/**
 * Interface that may be used for call operations like answer, reject, hang up and mid-call operations like hold, start/stop video and others.
 *
 * @namespace call
 */
@interface VICall : NSObject

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Video source currently used in the call.
 *
 * Default value:
 * - nil for audio calls,
 * - <[VICameraManager sharedCameraManager]> is used for video calls.
 *
 * Must be set before using <[VICall start]> and <[VICall answerWithSettings:]> if needed.
 */
@property(nonatomic, strong, nullable) VIVideoSource *videoSource;

/**
 * Add call delegate to handle call events.
 *
 * @param delegate Object registering as an delegate.
 */
- (void)addDelegate:(id <VICallDelegate>)delegate;

/**
 * Remove previously added delegate.
 *
 * @param delegate Previously added delegate.
 */
- (void)removeDelegate:(id <VICallDelegate>)delegate;

/**
 * The call id.
 */
@property(nonatomic, strong, readonly) NSString *callId;

/**
 * The CallKit UUID that may be used to match an incoming call with a push notification received before.
 *
 * Always nil for outgoing calls on VICall instance creation.
 *
 * For outgoing calls it is recommended to set [CXStartCallAction.callUUID](https://developer.apple.com/documentation/callkit/cxstartcallaction) value to this property on handling CXStartCallAction
 */
@property(nonatomic, strong, nullable) NSUUID *callKitUUID;

/**
 * An array of the endpoints associated with the call.
 */
@property(nonatomic, strong, readonly) NSArray<VIEndpoint *> *endpoints;

/**
 * A Boolean value that determines whether an audio is transferred from microphone into the call.
 *
 * Setting this property enables or disables audio transfer.
 */
@property(nonatomic, assign) BOOL sendAudio;

/**
 * A Boolean value that determines whether a video is enabled in the call.
 */
@property (nonatomic, assign, readonly, getter=isVideoEnabled) BOOL videoEnabled;

/**
 * Get the call duration.
 *
 * @return Call duration.
 */
- (NSTimeInterval)duration;

/**
 * Start outgoing call.
 */
- (void)start;

/**
 * Start or stop sending video for the call.
 *
 * Starting the version 2.34.3 the API behaves the same way for conference and video calls.
 *
 * For the version 2.34.2 and below for the conference video call mutes or un-mutes video send (video stream
 * in the 'muted' state will still consume a small bandwidth).
 *
 * @param video      YES if video should be sent, NO otherwise.
 * @param completion Completion block to handle the result of the operation.
 */
- (void)setSendVideo:(BOOL)video completion:(nullable VICompletionBlock)completion;

/**
 * Hold or unhold the call.
 *
 * Hold functionality is not supported in conference calls. In case of conference call it will return <VICallErrorCodeIncorrectOperation> via the completion block.
 *
 * @param hold       YES if the call should be put on hold, NO for unhold.
 * @param completion Completion block to handle the result of the operation.
 */
- (void)setHold:(BOOL)hold completion:(nullable VICompletionBlock)completion;

/**
 * Start receive video if video receive was not enabled before. Stop receiving video during the call is not supported.
 *
 * @param completion Completion block to handle the result of operation.
 */
- (void)startReceiveVideoWithCompletion:(nullable VICompletionBlock)completion;

/**
 * Send message within the call.
 * Implemented atop SIP INFO for communication between call endpoint and Voximplant cloud, and is separated from Voximplant messaging API.
 *
 * @param message Message text.
 */
- (void)sendMessage:(NSString *)message;

/**
 * Send INFO message within the call.
 *
 * @param body     Custom string data.
 * @param mimeType MIME type of info.
 * @param headers  Optional set of headers to be sent with message. Names must begin with "X-" to be processed by SDK
 */
- (void)sendInfo:(NSString *)body mimeType:(NSString *)mimeType headers:(nullable NSDictionary *)headers;

/**
 * Send DTMF within the call.
 *
 * @param dtmf DTMFs.
 * @return     YES if DTMFs are sent successfully, NO otherwise.
 */
- (BOOL)sendDTMF:(NSString *)dtmf;

/**
 * Answer incoming call.
 *
 * @param settings Call settings with additional call parameters, such as preferred video codec, custom data, extra headers etc.
 */
- (void)answerWithSettings:(VICallSettings *)settings;

/**
 * Reject incoming call.
 *
 * @param mode Specify mode of call rejection.
 * @param headers Optional set of headers to be sent with message. Names must begin with "X-" to be processed by SDK.
 */
- (void)rejectWithMode:(VIRejectMode)mode headers:(nullable NSDictionary *)headers;

/**
 * Terminates call. Call should be either established or outgoing progressing.
 *
 * @param headers Optional set of headers to be sent with message. Names must begin with "X-" to be processed by SDK.
 */
- (void)hangupWithHeaders:(nullable NSDictionary *)headers;

/**
 * Starts in-app screen sharing.
 *
 * Note that before recording actually starts, the user may be prompted with UI to confirm recording.
 *
 * Captures screen only inside the application. Simulator is not supported.
 *
 * Use <[VICall setSendVideo:completion:]> method with "sendVideo" variable "YES" value to return to the default capture mode (camera or custom camera mode).
 *
 * Use <[VICall setSendVideo:completion:]> method with "sendVideo" variable "NO" value to stop screen capturing.
 *
 * Video of the screen is sent in HD quality (720p).
 *
 * @param completion Completion block to handle the result of the operation.
 */
- (void)startInAppScreenSharing:(nullable VICompletionBlock)completion NS_SWIFT_NAME(startInAppScreenSharing(_:)) API_AVAILABLE(ios(11));

/**
 * Set <VIQualityIssueDelegate> to monitor issues that affect call quality.
 */
@property(weak, nonatomic, nullable) id <VIQualityIssueDelegate> qualityIssueDelegate;

/**
 * Get all quality issues types.
 *
 * @return array of <VIQualityIssueType>.
 */
- (NSArray<VIQualityIssueType> *)qualityIssues;

/**
 * Get current level of specific quality issue.
 *
 * @param type Quality issue type.
 * @return Issue level for that type.
 */
- (VIQualityIssueLevel)issueLevelForType:(VIQualityIssueType)type;

@end

@interface VICall (Streams)

/**
 * The local video streams associated with the call.
 */
@property(nonatomic, strong, readonly) NSArray<VILocalVideoStream *> *localVideoStreams;

@end


NS_ASSUME_NONNULL_END
