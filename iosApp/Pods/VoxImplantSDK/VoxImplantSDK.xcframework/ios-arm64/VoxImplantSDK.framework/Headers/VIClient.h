/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VIError.h"
#import "VIAuthParams.h"

@class VIClient;
@class VICall;
@class VIMessenger;
@class VICallSettings;

NS_ASSUME_NONNULL_BEGIN

/**
 * Log message types.
 *
 * @namespace client
 */
typedef NS_OPTIONS(NSUInteger, VILogSeverity) {
    /** Error level message. */
    VILogSeverityError = (1 << 20),
    /** Warning level message. */
    VILogSeverityWarning = (1 << 21),
    /** Info level message. */
    VILogSeverityInfo = (1 << 22),
    /** Debug level message. */
    VILogSeverityDebug = (1 << 23),
    /** Verbose level message. */
    VILogSeverityVerbose = (1 << 24),
};

/**
 * Logging level.
 *
 * @namespace client
 */
typedef NS_ENUM(NSUInteger, VILogLevel) {
    /** Mutes all log messages. */
    VILogLevelDisabled = 0,
    /** Log verbosity level to include only error messages. */
    VILogLevelError = (VILogSeverityError),
    /** Log verbosity level to include error and warnings messages. */
    VILogLevelWarning = (VILogLevelError | VILogSeverityWarning),
    /** Log verbosity level to include error, warnings and info messages. */
    VILogLevelInfo = (VILogLevelWarning | VILogSeverityInfo),
    /** Log verbosity level to include error, warnings, info and debug messages. */
    VILogLevelDebug = (VILogLevelInfo | VILogSeverityDebug),
    /** Log verbosity level to include error, warnings, info, debug and verbose messages. */
    VILogLevelVerbose = (VILogLevelDebug | VILogSeverityVerbose),
};

/**
 * Logging delegate
 *
 * @namespace client
 */
@protocol VILogDelegate <NSObject>

/**
 * Invoked for each log message from Voximplant iOS SDK
 *
 * @param message Log message
 * @param severity Severity of message
 */
- (void)didReceiveLogMessage:(NSString *)message severity:(VILogSeverity)severity;

@end

/**
 * VIClient states.
 *
 * @namespace client
 */
typedef NS_ENUM(NSUInteger, VIClientState) {
    /** The client is currently disconnected. */
    VIClientStateDisconnected,
    /** The client is currently connecting. */
    VIClientStateConnecting,
    /** The client is currently reconnecting. */
    VIClientStateReconnecting,
    /** The client is currently connected. */
    VIClientStateConnected,
    /** The client is currently logging in. */
    VIClientStateLoggingIn,
    /** The client is currently logged in. */
    VIClientStateLoggedIn
};

/**
 * Interface that may be used to connect and login to Voximplant Cloud, make and receive audio/video calls.
 *
 * @namespace client
 */
@interface VIClient : NSObject

/**
 * Get client version.
 *
 * @return Voximplant Client version.
 */
+ (NSString *)clientVersion;

/**
 * Get underlying WebRTC version.
 *
 * @return WebRTC version.
 */
+ (NSString *)webrtcVersion;

/**
 * Set log delegate to handle Voximplant iOS SDK log messages.
 *
 * @param logDelegate Log delegate instance
 */
+ (void)setLogDelegate:(id <VILogDelegate>)logDelegate;

/**
 * Set a verbosity level for log messages. This method must be called before creating SDK object instance.
 *
 * @param logLevel Log verbosity level.
 */
+ (void)setLogLevel:(VILogLevel)logLevel;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Initialize client instance.
 *
 * @param queue All delegates methods will be called on this queue. Queue should be serial, but not concurrent (main queue is applicable).
 * @return Client instance.
 */
- (instancetype)initWithDelegateQueue:(dispatch_queue_t)queue;

/**
 * Initialize a client instance.
 *
 * You need to use this only if you are going to send push notifications across several iOS apps using a single Voximplant application.
 *
 * @param queue All delegates methods will be called on this queue. Queue should be serial, but not concurrent (main queue is applicable).
 * @param bundleId Application bundle id
 * @return Client instance.
 */
- (instancetype)initWithDelegateQueue:(dispatch_queue_t)queue bundleId:(nullable NSString *)bundleId;

/**
 * Get the instance of messaging subsystem.
 *
 * Messenger instance.
 */
@property(nonatomic, strong, readonly) VIMessenger *messenger;

/**
 * Current client state.
 */
@property(nonatomic, readonly) VIClientState clientState;

@end

/**
 * Delegate that may be used to handle events for connection with Voximplant Cloud.
 *
 * @namespace client
 */
@protocol VIClientSessionDelegate <NSObject>

/**
 * Triggered after the connection to the Voximplant Cloud was established successfully.
 *
 * @param client Client instance.
 */
- (void)clientSessionDidConnect:(VIClient *)client;

/**
 * Triggered if the connection to the Voximplant Cloud was closed.
 *
 * @param client Client instance.
 */
- (void)clientSessionDidDisconnect:(VIClient *)client;

/**
 * Triggered if the connection to the Voximplant Cloud couldn't be established.
 *
 * @param client Client instance.
 * @param error  Occurred error. See <VIConnectivityErrorCode> for possible variants.
 */
- (void)client:(VIClient *)client sessionDidFailConnectWithError:(NSError *)error;

@optional
/**
 * Triggered if reconnection to Voximplant Cloud was started.
 *
 * @param client Client instance.
 */
- (void)clientSessionDidStartReconnecting:(VIClient *)client;

/**
 * Triggered after the connection to the Voximplant Cloud was established successfully after a reconnect.
 *
 * After the client is reconnected, <[VIClient clientState]> is changed to <VIClientStateLoggedIn>.
 *
 * @param client Client instance.
 */
- (void)clientSessionDidReconnect:(VIClient *)client;

@end

@interface VIClient (Session)

/**
 * Session delegate that handles events for the connection with the Voximplant Cloud.
 */
@property(nonatomic, weak, nullable) id <VIClientSessionDelegate> sessionDelegate;

/**
 * Connect to the Voximplant Cloud.
 *
 * @return YES if the attempt to connect can be performed, NO otherwise. Return value "NO" means that the connection to Voximplant Cloud is currently establishing or already established. In this case please check the current client state via <[VIClient clientState]> property and proceed according to the current state.
 */
- (BOOL)connect;

/**
 * Connect to the Voximplant Cloud.
 *
 * @param connectivityCheck Checks whether UDP traffic will flow correctly between device and Voximplant Cloud. This check reduces connection speed.
 * @param gateways          Array of server names of particular media gateways for connection.
 * @return                  YES if the attempt to connect can be performed, NO otherwise.
 *                          Return value NO means that the connection to Voximplant Cloud is currently establishing or already established. In this case please check the current client state via <[VIClient clientState]> property and proceed according to the current state.
 */
- (BOOL)connectWithConnectivityCheck:(BOOL)connectivityCheck gateways:(nullable NSArray *)gateways;

/**
 * Disconnect from the Voximplant Cloud.
 */
- (void)disconnect;

@end

/**
 * Completion handler, triggered when a login operation is completed successfully.
 *
 * @namespace client
 *
 * @param displayName Display name of logged in user.
 * @param authParams  Auth parameters that can be used to login using access token.
 */
typedef void (^VILoginSuccess)(NSString *displayName, VIAuthParams *__nullable authParams);

/**
 * Completion handler, triggered when login process failed.
 *
 * @namespace client
 *
 * @param error Occurred error. See <VILoginErrorCode> for possible variants.
 */
typedef void (^VILoginFailure)(NSError *error);

/**
 * Completion handler, triggered when a one time key generated by the login server.
 *
 * @namespace client
 *
 * @param oneTimeKey One time key.
 * @param error      Occurred error. See <VILoginErrorCode> for possible variants.
 */
typedef void (^VIOneTimeKeyResult)(NSString *__nullable oneTimeKey, NSError *__nullable error);

/**
 * Completion handler, triggered when refresh of login tokens is completed.
 *
 * @namespace client
 *
 * @param authParams Auth parameters that can be used to login using access token.
 * @param error      Occurred error. See <VILoginErrorCode> for possible variants.
 */
typedef void (^VIRefreshTokenResult)(VIAuthParams *__nullable authParams, NSError *__nullable error);

/**
 * Completion callback.
 *
 * @namespace client
 *
 * @param error An error object that indicates why the operation failed (see <VICallErrorCode> and <VIPushTokenErrorCode> for possible variants), or nil if the operation was successful.
 */
typedef void (^VICompletionBlock)(NSError *__nullable error);

@interface VIClient (Login)

/**
 * Login to the Voximplant Cloud using password.
 *
 * @param user     Full user name, including app and account name, like someuser@someapp.youraccount.voximplant.com.
 * @param password User password.
 * @param success  Completion handler triggered if operation is completed successfully.
 * @param failure  Completion handler failure triggered if operation is failed.
 */
- (void)loginWithUser:(NSString *)user
             password:(NSString *)password
              success:(nullable VILoginSuccess)success
              failure:(nullable VILoginFailure)failure;

/**
 * Login to the Voximplant Cloud using access token.
 *
 * @param user    Full user name, including app and account name, like someuser@someapp.youraccount.voximplant.com.
 * @param token   Access token obtained from authParams.
 * @param success Completion handler triggered if operation is completed successfully.
 * @param failure Completion handler failure triggered if operation is failed.
 */
- (void)loginWithUser:(NSString *)user
                token:(NSString *)token
              success:(nullable VILoginSuccess)success
              failure:(nullable VILoginFailure)failure;

/**
 * Login to the Voximplant Cloud using one time key.
 *
 * @param user       Full user name, including app and account name, like someuser@someapp.youraccount.voximplant.com.
 * @param oneTimeKey Hash that was generated using following formula:
 *                   ```objectivec
 *                   MD5(oneTimeKey+"|"+MD5(user+":voximplant.com:"+password))
 *                   ```
 *
 * Please note that here user is just a user name, without app name, account name or anything else after "@".
 *
 * So if you pass myuser@myapp.myacc.voximplant.com as a username, you should only use myuser while computing this hash.
 *
 * @param success    Completion handler triggered if operation is completed successfully.
 * @param failure    Completion handler failure triggered if operation is failed.
 */
- (void)loginWithUser:(NSString *)user
           oneTimeKey:(NSString *)oneTimeKey
              success:(nullable VILoginSuccess)success
              failure:(nullable VILoginFailure)failure;

/**
 * Perform refresh of login tokens required for login using access token.
 *
 * @param user   Full user name, including app and account name, like someuser@someapp.youraccount.voximplant.com.
 * @param token  Refresh token obtained from authParams.
 * @param result Completion handler that is triggered when the operation is completed.
 */
- (void)refreshTokenWithUser:(NSString *)user token:(NSString *)token result:(nullable VIRefreshTokenResult)result;

/**
 * Generates one time login key to be used for automated login process.
 *
 * For additional information please see:
 * - <[VIClient loginWithUser:oneTimeKey:success:failure:]>.
 * - [Information about automated login on Voximplant website](/docs/quickstart/24/automated-login/).
 *
 * @param user   Full user name, including app and account name, like someuser@someapp.youraccount.voximplant.com.
 * @param result Completion handler that is triggered when the operation is completed.
 */
- (void)requestOneTimeKeyWithUser:(NSString *)user result:(VIOneTimeKeyResult)result;

@end

/**
 * Delegate that may be used to handle incoming calls.
 *
 * @namespace client
 */
@protocol VIClientCallManagerDelegate <NSObject>

/**
 * Triggered when there is a new incoming call to current user.
 *
 * @param client  Client instance.
 * @param call    Call instance.
 * @param video   YES if incoming call offers video, NO otherwise.
 * @param headers Optional headers passed with event.
 */
- (void)client:(VIClient *)client didReceiveIncomingCall:(VICall *)call withIncomingVideo:(BOOL)video headers:(nullable NSDictionary *)headers;

/**
 * Triggered when a previously received VoIP push notification is expired, i.e. <[VIClientCallManagerDelegate client:didReceiveIncomingCall:withIncomingVideo:headers:]> will not be invoked for the specified callKitUUID.
 *
 * This method can be used for CallKit integration.
 *
 * It is recommended to end the CXCall via [CXProvider reportCallWithUUID:endedAtDate:reason] API on this method invocation.
 *
 * @param client  Client instance.
 * @param callKitUUID  CallKit UUID for the incoming call for which the push notification is expired. Always matches the callKitUUID returned from <[VIClient handlePushNotification:]> API.
 */
@optional
- (void)client:(VIClient *)client pushDidExpire:(NSUUID *)callKitUUID;

@end

@interface VIClient (CallManager)

/**
 * Call manager delegate that handles incoming calls.
 */
@property(nonatomic, weak, nullable) id <VIClientCallManagerDelegate> callManagerDelegate;

/**
 * Dictionary of actual calls with their ids.
 */
@property(nonatomic, strong, readonly) NSDictionary<NSString *, VICall *> *calls;

/**
 * A Boolean value that determines whether a video adaptation for CPU usage and current bandwidth is enabled.
 *
 * Setting this property enables or disables video adaptation for all calls since next call.
 *
 * Default is YES.
 */
@property(nonatomic, assign) BOOL enableVideoAdaptation;

/**
 * Force traffic to go through TURN servers
 *
 * Setting this property enables or disables traffic to go through TURN servers for all calls since next call.
 *
 * Default is NO.
 */
@property(nonatomic, assign) BOOL enableForceRelayTraffic;

/**
 * Create a new call instance. The call must be then started using <[VICall start]>.
 *
 * @param number   SIP URI, username or phone number to make call to. Actual routing is then performed by VoxEngine scenario.
 * @param settings Call settings with additional call parameters, such as preferred video codec, custom data, extra headers etc.
 * @return         Call instance or nil if client is not logged in or user is nil
 */
- (nullable VICall *)call:(NSString *)number settings:(VICallSettings *)settings;

/**
 * Create a call to a dedicated conference without proxy session. The call must be then started using <[VICall start]>.
 * For details see [the video conferencing guide](/docs/guides/conferences/howto).
 *
 * @param conference The number to call. For SIP compatibility reasons it should be a non-empty string even if the number itself is not used by a Voximplant cloud scenario.
 * @param settings   Call settings with additional call parameters, such as preferred video codec, custom data, extra headers etc.
 * @return           Call instance or nil if client is not logged in or conference is nil
 */
- (nullable VICall *)callConference:(NSString *)conference settings:(VICallSettings *)settings;

@end

@interface VIClient (Push)
/**
 * Register an Apple Push Notifications token.
 *
 * After calling this function application will receive push notifications from Voximplant Server.
 * If the provided tokens are not nil, but the client is not logged in, the tokens will be registered just after login, despite the API returns NO.
 *
 * @param voipToken The APNS token for VoIP push notifications which comes from [[PKPushRegistryDelegate pushRegistry:didUpdatePushCredentials:forType:]](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/1614470-pushregistry?language=objc).
 * @param imToken The APNS token for IM push notifications.
 *
 * @return YES if request was sent to Voximplant Server, NO otherwise
 */
- (BOOL)registerPushNotificationsToken:(nullable NSData *)voipToken imToken:(nullable NSData *)imToken DEPRECATED_MSG_ATTRIBUTE("Use [VIClient registerVoIPPushNotificationsToken:completion:] and [VIClient registerIMPushNotificationsToken:completion:] instead.");

/**
 * Register an Apple Push Notifications token.
 *
 * After calling this function application will receive push notifications from Voximplant Server.
 * If the provided token is not nil, but the client is not logged in, the token will be registered just after login.
 *
 * @param voipToken The APNS token for VoIP push notifications which comes from [[PKPushRegistryDelegate pushRegistry:didUpdatePushCredentials:forType:]](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/1614470-pushregistry?language=objc).
 * @param completion Completion block to handle the result of the operation.
 */
- (void)registerVoIPPushNotificationsToken:(NSData *)voipToken completion:(nullable VICompletionBlock)completion;

/**
 * Register an Apple Push Notifications token.
 *
 * After calling this function application will receive push notifications from Voximplant Server.
 * If the provided token is not nil, but the client is not logged in, the token will be registered just after login.
 *
 * @param imToken The APNS token for IM push notifications.
 * @param completion Completion block to handle the result of the operation.
 */
- (void)registerIMPushNotificationsToken:(NSData *)imToken completion:(nullable VICompletionBlock)completion;

/**
 * Unregister an Apple Push Notifications token.
 *
 * After calling this function application stops receive push notifications from Voximplant Server.
 * If the provided tokens are not nil, but the client is not logged in, the tokens will be unregistered just after login, despite the API returns NO.
 *
 * @param voipToken The APNS token for VoIP push notifications which comes from [[PKPushRegistryDelegate pushRegistry:didUpdatePushCredentials:forType:]](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/1614470-pushregistry?language=objc).
 * @param imToken The APNS token for IM push notification.
 *
 * @return YES if request was sent to Voximplant Server, NO otherwise
 */
- (BOOL)unregisterPushNotificationsToken:(nullable NSData *)voipToken imToken:(nullable NSData *)imToken DEPRECATED_MSG_ATTRIBUTE("Use [VIClient unregisterVoIPPushNotificationsToken:completion:] and [VIClient unregisterIMPushNotificationsToken:completion:] instead.");

/**
 * Unregister an Apple Push Notifications token.
 *
 * After calling this function application stops receive push notifications from Voximplant Server.
 * If the provided token is not nil, but the client is not logged in, the token will be unregistered just after login.
 *
 * @param voipToken The APNS token for VoIP push notifications which comes from [[PKPushRegistryDelegate pushRegistry:didUpdatePushCredentials:forType:]](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/1614470-pushregistry?language=objc).
 * @param completion Completion block to handle the result of the operation.
 */
- (void)unregisterVoIPPushNotificationsToken:(NSData *)voipToken completion:(nullable VICompletionBlock)completion;

/**
 * Unregister an Apple Push Notifications token.
 *
 * After calling this function application stops receive push notifications from Voximplant Server.
 * If the provided token is not nil, but the client is not logged in, the token will be unregistered just after login.
 *
 * @param imToken The APNS token for IM push notification.
 * @param completion Completion block to handle the result of the operation.
 */
- (void)unregisterIMPushNotificationsToken:(NSData *)imToken completion:(nullable VICompletionBlock)completion;

/**
 * Handle an incoming push notification.
 *
 * @param notification The incoming notification which comes from [[PKPushRegistryDelegate pushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:]](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/2875784-pushregistry?language=objc).
 *
 * @return CallKit UUID if the push notification was received from the Voximplant Cloud, nil otherwise.
 * CallKit UUID matches <VICall.callKitUUID> only for the incoming call this push notification was sent for. CallKit UUID may be used to match [CXCall](https://developer.apple.com/documentation/callkit/cxcall) and <VICall> instances.
 */
- (nullable NSUUID *)handlePushNotification:(nullable NSDictionary *)notification;

@end

NS_ASSUME_NONNULL_END
