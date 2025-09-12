/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class VIMessenger;
@class VIConversationConfig;
@class VIConversationParticipant;
@class VIConversation;
@class VIMessage;
@class VIUser;

#import "VIMessengerCompletion.h"

@class VIMessengerEvent;
@class VISubscriptionEvent;
@class VIErrorEvent;
@class VIUserEvent;
@class VIStatusEvent;
@class VIConversationEvent;
@class VIConversationListEvent;
@class VIMessageEvent;
@class VIRetransmitEvent;
@class VIConversationServiceEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Enum that represents events available for push notification subscriptions.
 *
 * Use the <[VIMessenger managePushNotifications:completion:]> method
 * to subscribe for push notifications.
 *
 * @namespace messaging
 */
typedef NSString *VIMessengerNotification NS_STRING_ENUM;
FOUNDATION_EXPORT VIMessengerNotification const VIMessengerNotificationEditMessage;
FOUNDATION_EXPORT VIMessengerNotification const VIMessengerNotificationSendMessage;

/**
 * Delegate that may be used to handle messenger events.
 *
 * Methods are invoked either on:
 * - the current user's side only. The events always invoked only on a client
 *   where messaging methods are called (unless otherwise specified).
 * - or both current user's and other participants' sides.
 *
 * See the details in the methods' descriptions.
 *
 * A queue on which all events will be received is specified via
 * <[VIClient initWithDelegateQueue:]>.
 *
 * @namespace messaging
 */
@protocol VIMessengerDelegate <NSObject>

@optional
/**
 * Invoked as the result of:
 * - <[VIMessenger getUserByIMId:completion:]>
 * - <[VIMessenger getUserByName:completion:]>
 * - <[VIMessenger getUsersByIMId:completion:]>
 * - <[VIMessenger getUsersByName:completion:]>
 *
 * Triggered only on the current user's side.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with user data and service information
 */
- (void)messenger:(VIMessenger *)messenger didGetUser:(VIUserEvent *)event;

/**
 * Invoked as the result of
 * <[VIMessenger editUserWithCustomData:privateCustomData:completion:]>,
 * <[VIMessenger managePushNotifications:completion:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered only for the subscribers of the changed user. Use
 * <[VIMessenger subscribe:completion:]> to subscribe for
 * user's changes.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with user data and service information
 */
- (void)messenger:(VIMessenger *)messenger didEditUser:(VIUserEvent *)event;

/**
 * Invoked as the result of
 * <[VIMessenger subscribe:completion:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered on all logged in clients of the current user
 *
 * @param messenger Instance of messenger
 * @param event     Event object with subscription data and service information
 */
- (void)messenger:(VIMessenger *)messenger didSubscribe:(VISubscriptionEvent *)event;

/**
 * Invoked as the result of
 * <[VIMessenger unsubscribe:completion:]>,
 * <[VIMessenger unsubscribeFromAll:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered on all logged in clients of the current user.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with subscription data and service information
 */
- (void)messenger:(VIMessenger *)messenger didUnsubscribe:(VISubscriptionEvent *)event;

/**
 * Invoked as the result of the <[VIMessenger getSubscriptionList:]>
 * method call.
 *
 * Triggered only on the current user's side.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with subscription data and service information
 */
- (void)messenger:(VIMessenger *)messenger didGetSubscriptionList:(VISubscriptionEvent *)event;

/**
 * Invoked when a conversation is created via
 * <[VIMessenger createConversation:completion:]>
 * or analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered only for participants that belong to the conversation.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with conversation data and service information
 */
- (void)messenger:(VIMessenger *)messenger didCreateConversation:(VIConversationEvent *)event;

/**
 * Invoked when a conversation was removed.
 *
 * Note that removing is possible via Voximplant Messaging API only.
 *
 * Triggered only for participants that belong to the conversation.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with conversation data and service info
 */
- (void)messenger:(VIMessenger *)messenger didRemoveConversation:(VIConversationEvent *)event;

/**
 * Invoked when a conversation description is received as the result of the
 * <[VIMessenger getConversation:completion:]>
 * or <[VIMessenger getConversations:completion:]> methods calls.
 *
 * Triggered only on the current user's side.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with conversation data and service information
 */
- (void)messenger:(VIMessenger *)messenger didGetConversation:(VIConversationEvent *)event;

/**
 * Invoked when the array of public conversations UUIDs is received as the result of the
 * <[VIMessenger getPublicConversations:]> method call.
 *
 * Triggered only on the current user's side.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with public conversations UUIDs and service information
 */
- (void)messenger:(VIMessenger *)messenger didGetPublicConversations:(VIConversationListEvent *)event;

/**
 * Invoked when the conversation properties were modified as the result of:
 * - <[VIMessenger joinConversation:completion:]>
 * - <[VIMessenger leaveConversation:completion:]>
 * - <[VIConversation update:]>
 * - <[VIConversation addParticipants:completion:]>
 * - <[VIConversation removeParticipants:completion:]>
 * - <[VIConversation editParticipants:completion:]>
 * - or analogous methods from other Voximplant SDKs and Messaging API
 *
 * Triggered only for participants that belong to the conversation.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with conversation data and service information
 */
- (void)messenger:(VIMessenger *)messenger didEditConversation:(VIConversationEvent *)event;

/**
 * Invoked after a user status was changed via
 * <[VIMessenger setStatus:completion:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered only for the subscribers of the changed user. Use
 * <[VIMessenger subscribe:completion:]> to subscribe for
 * a user's changes.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with user status data and service information
 */
- (void)messenger:(VIMessenger *)messenger didSetStatus:(VIStatusEvent *)event;

/**
 * Invoked when a message was edited via
 * <[VIMessage update:payload:completion:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered only for participants that belong to the conversation with the changed message.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with message data and service information
 */
- (void)messenger:(VIMessenger *)messenger didEditMessage:(VIMessageEvent *)event;

/**
 * Invoked when a new message was sent to a conversation via
 * <[VIConversation sendMessage:payload:completion:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered only for participants that belong to the conversation.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with message data and service information
 */
- (void)messenger:(VIMessenger *)messenger didSendMessage:(VIMessageEvent *)event;

/**
 * Invoked when a message was removed from a conversation via
 * <[VIMessage remove:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered only for participants that belong to the conversation with the deleted message.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with message data and service information
 */
- (void)messenger:(VIMessenger *)messenger didRemoveMessage:(VIMessageEvent *)event;

/**
 * Invoked when some user is typing text in a conversation. Information about typing is
 * received via <[VIConversation typing:]> or
 * analogous methods from other Voximplant SDKs and Messaging API.
 *
 * Triggered only for participants that belong to the conversation where typing is performing.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with conversation UUID and service information
 */
- (void)messenger:(VIMessenger *)messenger didReceiveTypingNotification:(VIConversationServiceEvent *)event;

/**
 * Invoked for all clients in the conversation as the result of
 * <[VIConversation markAsRead:completion:]>
 * or analogous methods from other Voximplant SDKs and Messaging API.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with conversation UUID and service information
 */
- (void)messenger:(VIMessenger *)messenger didReceiveReadConfirmation:(VIConversationServiceEvent *)event;

/**
 * Invoked when an error occurred as the result of any
 * Voximplant iOS Messaging API methods call.
 *
 * Triggered only on the current user's side.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with error details and service information
 */
- (void)messenger:(VIMessenger *)messenger didReceiveError:(VIErrorEvent *)event;

/**
 * Invoked as the result of the following methods calls on some conversation
 * for this SDK instance:
 * - <[VIConversation retransmitEventsFrom:to:completion:]>,
 * - <[VIConversation retransmitEventsFrom:count:completion:]>,
 * - <[VIConversation retransmitEventsTo:count:completion:]>
 *
 * Triggered only on the current user's side.
 *
 * @param messenger Instance of messenger
 * @param event     Event object with retransmitted events and service information
 */
- (void)messenger:(VIMessenger *)messenger didRetransmitEvents:(VIRetransmitEvent *)event;

@end

/**
 * Interface that may be used to control messaging functions.
 *
 * @namespace messaging
 */
@interface VIMessenger : NSObject

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * An Voximplant user identifier for the current user (e.g., 'username@appname.accname'),
 * or nil if the client is not logged in.
 */
@property(nonatomic, strong, readonly, nullable) NSString *me;

/**
 * Add delegate to handle messenger events.
 *
 * @param delegate Instance to be added as delegate.
 */
- (void)addDelegate:(id <VIMessengerDelegate>)delegate NS_SWIFT_NAME(addDelegate(_:));

/**
 * Remove a previously added delegate.
 *
 * @param delegate Delegate to be removed.
 */
- (void)removeDelegate:(id <VIMessengerDelegate>)delegate NS_SWIFT_NAME(removeDelegate(_:));

/**
 * Get information for the user specified by the Voximplant user name,
 * e.g., 'username@appname.accname'.
 *
 * It's possible to get any user of the main Voximplant developer account
 * or its child accounts.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIUserEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didGetUser:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Only the client that called the method can be informed about
 * getting user information.
 *
 * @param username    Voximplant user identifier
 * @param completion  Completion handler to get the result or nil
 */
- (void)getUserByName:(NSString *)username completion:(nullable VIMessengerCompletion<VIUserEvent *> *)completion;

/**
 * Get information for the user specified by the IM user id.
 *
 * It's possible to get any user of the main Voximplant developer account
 * or its child accounts.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIUserEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didGetUser:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Only the client that called the method can be informed about
 * getting user information.
 *
 * @param imId        IM User id
 * @param completion  Completion handler to get the result or nil
 */
- (void)getUserByIMId:(NSNumber *)imId completion:(nullable VIMessengerCompletion<VIUserEvent *> *)completion;

/**
 * Get information for the users specified by the array of the Voximplant user names.
 *  Maximum 50 users.
 *
 * It's possible to get any users of the main Voximplant developer account
 * or its child accounts.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIUserEvent> or <VIErrorEvent>
 *    in case of success/error accordingly. The result will be an array with as many
 *    user events as the specified number of user names is.
 * 2. Implement the <[VIMessengerDelegate messenger:didGetUser:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events. The event with a result
 *    will be invoked as many times as the specified number of user names is;
 *    the error event will be called once only.
 *
 * Only the client that called the method can be informed about
 * getting users information.
 *
 * @param users      Array of Voximplant user identifiers, e.g., 'username@appname.accname'
 * @param completion Completion handler to get the result or nil
 */
- (void)getUsersByName:(NSArray<NSString *> *)users completion:(nullable VIMessengerCompletion<NSArray<VIUserEvent *> *> *)completion;

/**
 * Get information for the users specified by the array of the IM user ids.
 * Maximum 50 users.
 *
 * It's possible to get any users of the main Voximplant developer account
 * or its child accounts.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIUserEvent> or <VIErrorEvent>
 *    in case of success/error accordingly. The result will be an array with as many
 *    user events as the specified number of IM user IDs is.
 * 2. Implement the <[VIMessengerDelegate messenger:didGetUser:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events. The event with a result
 *    will be invoked as many times as the specified number of IM user ids is;
 *    the error event will be called once only.
 *
 * Only the client that called the method can be informed about
 * getting users information.
 *
 * @param imIds       Array of IM user ids
 * @param completion  Completion handler to get the result or nil
 */
- (void)getUsersByIMId:(NSArray<NSNumber *> *)imIds completion:(nullable VIMessengerCompletion<NSArray<VIUserEvent *> *> *)completion;

/**
 * Edit current user information.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIUserEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditUser:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other users that are subscribed to the user
 * can be informed about the editing via the
 * <[VIMessengerDelegate messenger:didEditUser:]> event.
 *
 * @param customData        New custom data. If nil, previously set custom data will not be changed.
 *                          If empty dictionary, previously set custom data will be removed.
 * @param privateCustomData New private custom data. If nil, previously set private custom data will not be changed.
 *                          If empty dictionary, previously set private custom data will be removed.
 * @param completion        Completion handler to get the result or nil
 */
- (void)editUserWithCustomData:(nullable NSDictionary *)customData privateCustomData:(nullable NSDictionary *)privateCustomData completion:(nullable VIMessengerCompletion<VIUserEvent *> *)completion;

/**
 * Subscribe for other user(s) information and status changes.
 *
 * It's possible to subscribe for any user of the main Voximplant developer account
 * or its child accounts.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VISubscriptionEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didSubscribe:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other logged in clients (of the current user) can be informed about
 * the subscription via
 * the <[VIMessengerDelegate messenger:didSubscribe:]> event.
 * User(s) specified in the 'users' parameter aren't informed about the subscription.
 *
 * @param users      Array of IM user ids
 * @param completion Completion handler to get the result or nil
 */
- (void)subscribe:(NSArray<NSNumber *> *)users completion:(nullable VIMessengerCompletion<VISubscriptionEvent *> *)completion;

/**
 * Unsubscribe from other user(s) information and status changes.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VISubscriptionEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didUnsubscribe:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other logged in clients (of the current user) can be informed about
 * the unsubscription via
 * the <[VIMessengerDelegate messenger:didUnsubscribe:]> event.
 * User(s) specified in the 'users' parameter aren't informed about the unsubscription.
 *
 * @param users      Array of IM user ids
 * @param completion Completion handler to get the result or nil
 */
- (void)unsubscribe:(NSArray<NSNumber *> *)users completion:(nullable VIMessengerCompletion<VISubscriptionEvent *> *)completion;

/**
 * Unsubscribe from all subscriptions.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VISubscriptionEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didUnsubscribe:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other logged in clients (of the current user) can be informed about
 * the unsubscription via
 * the <[VIMessengerDelegate messenger:didUnsubscribe:]> event.
 * Other users aren't informed about the unsubscription.
 *
 * @param completion Completion handler to get the result or nil
 */
- (void)unsubscribeFromAll:(nullable VIMessengerCompletion<VISubscriptionEvent *> *)completion NS_SWIFT_NAME(unsubscribeFromAll(completion:));

/**
 * Get all current subscriptions, i.e., the array of users the current user is subscribed to.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VISubscriptionEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the
 *    <[VIMessengerDelegate messenger:didGetSubscriptionList:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Only the client that called the method can be informed about
 * getting subscriptions.
 *
 * @param completion Completion handler to get the result or nil
 */
- (void)getSubscriptionList:(nullable VIMessengerCompletion<VISubscriptionEvent *> *)completion NS_SWIFT_NAME(getSubscriptionList(completion:));

/**
 * Set the current user status.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIStatusEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didSetStatus:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other users (that are subscribed to the user) and other clients (of the current user)
 * can be informed about the status changing via the
 * <[VIMessengerDelegate messenger:didSetStatus:]> event.
 *
 * @param online     YES if user is available for messaging, NO otherwise
 * @param completion Completion handler to get the result or nil
 */
- (void)setStatus:(BOOL)online completion:(nullable VIMessengerCompletion<VIStatusEvent *> *)completion NS_SWIFT_NAME(setStatus(online:completion:));

/**
 * Create a new conversation with the extended configuration.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didCreateConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about the conversation creation via
 * the <[VIMessengerDelegate messenger:didCreateConversation:]> event.
 *
 * @param conversationConfig Config instance with extended conversation parameters
 * @param completion         Completion handler to get the result or nil
 */
- (void)createConversation:(VIConversationConfig *)conversationConfig completion:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion;

/**
 * Get a conversation by its UUID.
 *
 * It's possible if:
 * - the user that calls the method is/was a participant of this conversation
 * - the conversation is an available public conversation,
 *   see <[VIMessenger getPublicConversations:]>
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didGetConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Only the client that called the method can be informed about
 * getting conversation.
 *
 * @param uuid       Conversation UUID
 * @param completion Completion handler to get the result or nil
 */
- (void)getConversation:(NSString *)uuid completion:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion;

/**
 * Get the multiple conversations by the array of UUIDs. Maximum 30 conversations.
 *
 * It's possible if:
 * - the user that calls the method is/was a participant of these conversations
 * - the conversations are the available public conversations,
 *   see <[VIMessenger getPublicConversations:]>
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly. The result will be an array with as many
 *    conversations events as the specified number of conversations UUIDs is.
 * 2. Implement the <[VIMessengerDelegate messenger:didGetConversation:]>
 *    and
 *    <[VIMessengerDelegate messenger:didReceiveError:]> events. The event with a result
 *    will be invoked as many times as the specified number of conversations UUIDs is;
 *    the error event will be called once only.
 *
 * Only the client that called the method can be informed about
 * getting conversations.
 *
 * @param uuids      Array of conversation UUIDs. Maximum 30 conversations.
 * @param completion Completion handler to get the result or nil
 */
- (void)getConversations:(NSArray<NSString *> *)uuids completion:(nullable VIMessengerCompletion<NSArray<VIConversationEvent *> *> *)completion;

/**
 * Get all public conversations (<[VIConversation publicJoin]> is YES).
 *
 * It's possible to get all public conversations (UUIDs) that were created by:
 * - the current user
 * - other users of the same [child account](/docs/references/httpapi/managing_accounts#addaccount)
 * - users of the main Voximplant developer account
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationListEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the
 *    <[VIMessengerDelegate messenger:didGetPublicConversations:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Only the client that called the method can be informed about
 * getting public conversations UUIDs.
 *
 * @param completion Completion handler to get the result or nil
 */
- (void)getPublicConversations:(nullable VIMessengerCompletion<VIConversationListEvent *> *)completion NS_SWIFT_NAME(getPublicConversations(completion:));

/**
 * Join the current user to any conversation specified by the UUID.
 *
 * It's possible only on the following conditions:
 * - a conversation is created by a user of the main Voximplant developer account
 *   or its child accounts
 * - public join is enabled (<[VIConversation publicJoin]> is YES)
 * - the conversation is not a direct one (<[VIConversation direct]> is NO)
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about joining to the conversation via
 * the <[VIMessengerDelegate messenger:didEditConversation:]> event.
 *
 * @param uuid       Conversation UUID
 * @param completion Completion handler to get the result or nil
 */
- (void)joinConversation:(NSString *)uuid completion:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion;

/**
 * Make the current user to leave a conversation specified by the UUID.
 *
 * It's possible only if the conversation is not a direct one
 * (<[VIConversation direct]> is NO)
 *
 * After a successful method call the conversation's UUID will be added to
 * <[VIUser leaveConversationList]>.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about leaving the conversation via
 * the <[VIMessengerDelegate messenger:didEditConversation:]> event.
 *
 * @param uuid       Conversation UUID
 * @param completion Completion handler to get the result or nil
 */
- (void)leaveConversation:(NSString *)uuid completion:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion;

/**
 * Recreate a conversation.
 *
 * Note that this method does not create a conversation,
 * but restore a previously created conversation from a local storage (database).
 *
 * @param config             Conversation config
 * @param uuid               Conversation UUID
 * @param lastSequence       Sequence of the last event stored in a local storage (database)
 * @param lastUpdateTime     UNIX timestamp that specifies the time of the last event
 *                           stored in a local storage (database)
 * @param createdTime        UNIX timestamp that specifies the time of the conversation creation
 * @return <VIConversation> object or nil if uuid is nil or empty string
 */
- (nullable VIConversation *)recreateConversation:(VIConversationConfig *)config
                                             uuid:(NSString *)uuid
                                     lastSequence:(SInt64)lastSequence
                                   lastUpdateTime:(NSTimeInterval)lastUpdateTime
                                      createdTime:(NSTimeInterval)createdTime;

/**
 * Recreate a message.
 *
 * Note that this method does not create a message,
 * but restore a previously created message from a local storage (database).
 *
 * @param uuid             Universally unique identifier of message
 * @param conversationUUID UUID of the conversation this message belongs to
 * @param text             Text of this message
 * @param payload          Array of payload objects associated with the message
 * @param sequence         Message sequence number
 * @return <VIMessage> object or nil if uuid or conversationUUID is nil or empty string
 */
- (nullable VIMessage *)recreateMessage:(NSString *)uuid
                           conversation:(NSString *)conversationUUID
                                   text:(nullable NSString *)text
                                payload:(nullable NSArray<NSDictionary<NSString *, NSObject *> *> *)payload
                               sequence:(SInt64)sequence;

/**
 * Manage messenger push notification subscriptions for the current user.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 * <VIUserEvent> or <VIErrorEvent>
 * in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditUser:]>
 * and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other logged in clients (of the current user) can be informed about
 * managing push notifications via
 * <[VIMessengerDelegate messenger:didEditUser:]>.
 *
 * @param notifications Array of <VIMessengerNotification>
 * @param completion    Completion handler to get the result or nil
 */
- (void)managePushNotifications:(nullable NSArray<VIMessengerNotification> *)notifications completion:(nullable VIMessengerCompletion<VIUserEvent *> *)completion;

@end

NS_ASSUME_NONNULL_END
