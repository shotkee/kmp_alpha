/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "VIMessengerCompletion.h"

@class VIMessage;
@class VIMessageEvent;
@class VIConversationEvent;
@class VIConversationParticipant;
@class VIConversationServiceEvent;
@class VIRetransmitEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that may be used to manage conversation.
 *
 * @namespace messaging
 */
@interface VIConversation : NSObject

/**
 * A UNIX timestamp (seconds) that specifies the time of the conversation creation.
 */
@property(nonatomic, assign, readonly) NSTimeInterval createdTime;

/**
 * A custom data, up to 5kb.
 *
 * Note that changing this property value does not send changes to the cloud.
 * Use <[VIConversation update:]> to send all changes at once.
 */
@property(nonatomic, copy) NSDictionary<NSString *, NSObject *> *customData;

/**
 * A Boolean value that determines whether the conversation is direct.
 *
 * A direct conversation can't be uber and/or public.
 *
 * There can be only 2 participants in a direct conversation which is unique and the
 * only one for these participants. There can't be more than 1 direct conversation for
 * the same 2 users.
 *
 * If one of these users tries to create
 * a new direct conversation with the same participant via
 * <[VIMessenger createConversation:completion:]>
 * the method will return the UUID of the already existing direct conversation.
 */
@property(nonatomic, assign, readonly, getter=isDirect) BOOL direct;

/**
 * An array of participants alongside with their permissions.
 */
@property(nonatomic, strong, readonly) NSArray<VIConversationParticipant *> *participants;

/**
 * A Boolean value that determines whether the conversation is public.
 *
 * If YES, anyone can join the conversation by UUID.
 *
 * A public conversation can't be direct.
 *
 * Note that changing this property value does not send changes to the cloud.
 * Use <[VIConversation update:]> to send all changes at once
 */
@property(nonatomic, assign, getter=isPublicJoin) BOOL publicJoin;

/**
 * The current conversation title.
 *
 * Note that changing this property value does not send changes to the cloud.
 * Use <[VIConversation update:]> to send all changes at once
 */
@property(nonatomic, copy, nullable) NSString *title;

/**
 * An universally unique identifier (UUID) of this conversation.
 */
@property(nonatomic, strong, readonly) NSString *uuid;

/**
 * A UNIX timestamp (seconds) that specifies the time when one of
 * <VIConversationEvent> or <VIMessageEvent> was the last provoked event in this conversation.
 */
@property(nonatomic, assign, readonly) NSTimeInterval lastUpdateTime;

/**
 * The sequence of the last event in the conversation.
 */
@property(nonatomic, assign, readonly) SInt64 lastSequence;

/**
 * A Boolean value that determines whether the conversation is uber.
 *
 * A uber conversation can't be direct.
 *
 * Users in a uber conversation will not be able to retrieve messages that were posted
 * to the conversation after they quit.
 */
@property(nonatomic, assign, readonly, getter=isUber) BOOL uber;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Send conversation changes to the cloud. The sent changes are: title, public join flag
 * and custom data.
 *
 * Successful update will happen if a participant is the owner
 * (<[VIConversationParticipant owner]> is YES).
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about changing the title or custom data and enabling/disabling public join via
 * the <[VIMessengerDelegate messenger:didEditConversation:]> event.
 *
 * @param completion Completion handler to get the result or nil
 */
- (void)update:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion NS_SWIFT_NAME(update(completion:));

/**
 * Add new participants to the conversation.
 *
 * It's possible only on the following conditions:
 * - the participants are users of the main Voximplant developer account
 *   or its child accounts
 * - the current user can manage other participants
 *   (<[VIConversationParticipant canManageParticipants]> is YES)
 * - the conversation is not a direct one (<[VIConversation direct]> is NO)
 *
 * Duplicated users are ignored. Will cause <VIErrorEvent> if at least one user does not exist or
 * already belongs to the conversation.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about adding participants via
 * the <[VIMessengerDelegate messenger:didEditConversation:]> event.
 *
 * @param participants Array of <VIConversationParticipant> to be added to the conversation.
 *                     Shouldn't be nil or empty array.
 * @param completion   Completion handler to get the result or nil
 */
- (void)addParticipants:(NSArray<VIConversationParticipant *> *)participants completion:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion;

/**
 * Remove participants from the conversation.
 *
 * It's possible only on two conditions:
 * - the current user can manage other participants
 *   (<[VIConversationParticipant canManageParticipants]> is YES).
 * - the conversation is not a direct one (<[VIConversation direct]> is NO)
 *
 * Duplicated users are ignored. Will cause <VIErrorEvent> if at least one user:
 * - does not exist
 * - is already removed
 *
 * Note that you can remove participants that are marked as deleted
 * (<[VIUser deleted]> is YES).
 *
 * The removed users can later get this conversation's UUID via the
 * <[VIUser leaveConversationList]> method.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about removing participants via
 * the <[VIMessengerDelegate messenger:didEditConversation:]> event.
 *
 * @param participants Array of <VIConversationParticipant> to be removed from the conversation.
 *                     Shouldn't be nil or empty array.
 * @param completion   Completion handler to get the result or nil
 */
- (void)removeParticipants:(NSArray<VIConversationParticipant *> *)participants completion:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion;

/**
 * Edit participants' permissions. It's possible only if the current user
 * can manage other participants
 * (<[VIConversationParticipant canManageParticipants]> is YES).
 *
 * Duplicated users are ignored. Will cause <VIErrorEvent> if at least one user does not exist or
 * belong to the conversation.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIConversationEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditConversation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about editing participants via
 * the <[VIMessengerDelegate messenger:didEditConversation:]> event.
 *
 * @param participants Array of <VIConversationParticipant> to be edited in the conversation.
 *                     Shouldn't be nil or empty array.
 * @param completion   Completion handler to get the result or nil
 */
- (void)editParticipants:(NSArray<VIConversationParticipant *> *)participants completion:(nullable VIMessengerCompletion<VIConversationEvent *> *)completion;

/**
 * Send a message to the conversation.
 *
 * Sending messages is available only for participants that have write permissions
 * (<[VIConversationParticipant canWrite]> is YES).
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIMessageEvent} or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didSendMessage:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about sending messages to the conversation via
 * the Implement the <[VIMessengerDelegate messenger:didSendMessage:]> event.
 *
 * To be informed about sending messages while being offline, participants can
 * subscribe to the <VIMessengerNotificationSendMessage> messenger push notification.
 *
 * @param text       Message text, maximum 5000 characters
 * @param payload    Message payload
 * @param completion Completion handler to get the result or nil
 */
- (void)sendMessage:(nullable NSString *)text payload:(nullable NSArray<NSDictionary<NSString *, NSObject *> *> *)payload completion:(nullable VIMessengerCompletion<VIMessageEvent *> *)completion;

/**
 * Request events in the specified sequence range to be sent from the cloud to this client.
 *
 * Only <VIConversationEvent> and <VIMessageEvent> events can be retransmitted;
 * any other events can't be retransmitted.
 *
 * The method is used to get history or missed events in case of network disconnect.
 * Client should use this method to request all events based on the
 * last event sequence received from the cloud and last event sequence saved locally (if any).
 *
 * The maximum amount of retransmitted events per method call is 100.
 * Requesting more than 100 events will cause <VIErrorEvent>.
 *
 * If the current user quits a <[VIConversation uber]> conversation,
 * messages that are posted during the user's absence will not be retransmitted later.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIRetransmitEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didRetransmitEvents:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * @param from       First event in sequence range, inclusive
 * @param to         Last event in sequence range, inclusive
 * @param completion Completion handler to get the result or nil
 */
- (void)retransmitEventsFrom:(SInt64)from to:(SInt64)to completion:(nullable VIMessengerCompletion<VIRetransmitEvent *> *)completion;

/**
 * Request a number of events starting with the specified sequence
 * to be sent from the cloud to this client.
 *
 * Only <VIConversationEvent> and <VIMessageEvent> events can be retransmitted;
 * any other events can't be retransmitted.
 *
 * The method is used to get history or missed events in case of network disconnect.
 * Client should use this method to request all events based on the
 * last event sequence received from the cloud and last event sequence saved locally (if any).
 *
 * The maximum amount of retransmitted events per method call is 100.
 * Requesting more than 100 events will cause <VIErrorEvent>.
 *
 * If the current user quits a <[VIConversation uber]> conversation,
 * messages that are posted during the user's absence will not be retransmitted later.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIRetransmitEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didRetransmitEvents:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * @param from       First event in sequence range, inclusive
 * @param count      Number of events
 * @param completion Completion handler to get the result or nil
 */
- (void)retransmitEventsFrom:(SInt64)from count:(NSUInteger)count completion:(nullable VIMessengerCompletion<VIRetransmitEvent *> *)completion;

/**
 * Request a number of events up to the specified sequence
 * to be sent from the cloud to this client.
 *
 * Only <VIConversationEvent> and <VIMessageEvent> events can be retransmitted;
 * any other events can't be retransmitted.
 *
 * The method is used to get history or missed events in case of network disconnect.
 * Client should use this method to request all events based on the
 * last event sequence received from the cloud and last event sequence saved locally (if any).
 *
 * The maximum amount of retransmitted events per method call is 100.
 * Requesting more than 100 events will cause <VIErrorEvent>.
 *
 * If the current user quits a <[VIConversation uber]> conversation,
 * messages that are posted during the user's absence will not be retransmitted later.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIRetransmitEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didRetransmitEvents:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * @param to         Last event in sequence range, inclusive
 * @param count      Number of events
 * @param completion Completion handler to get the result or nil
 */
- (void)retransmitEventsTo:(SInt64)to count:(NSUInteger)count completion:(nullable VIMessengerCompletion<VIRetransmitEvent *> *)completion;

/**
 * Inform the cloud that the user is typing some text.
 *
 * The method calls within 10s interval from the last call cause <VIErrorEvent>.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 * <VIConversationServiceEvent> or <VIErrorEvent>
 * in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didReceiveTypingNotification:]>
 * and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about typing via
 * the <[VIMessengerDelegate messenger:didReceiveTypingNotification:]> event.
 *
 * @param completion Completion handler to get the result or nil
 */
- (void)typing:(nullable VIMessengerCompletion<VIConversationServiceEvent *> *)completion NS_SWIFT_NAME(typing(completion:));

/**
 * Mark the event with the specified sequence as read.
 *
 * A method call with the specified sequence makes the
 * <[VIConversationParticipant lastReadEventSequence]> property
 * return this sequence, i.e., such sequences can be get for each participant separately.
 *
 * If the sequence parameter specified less than 1,
 * the method will mark all the events as **unread** (for this participant) except
 * the event with the sequence equals to '1'.
 *
 * To get the method call result use one of the following options:
 * 1. Specify the handler parameter to consume the results with
 *    <VIConversationServiceEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didReceiveReadConfirmation:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about marking events as read via
 * the <[VIMessengerDelegate messenger:didReceiveReadConfirmation:]> event.
 *
 * @param sequence   Sequence number of the event in the conversation to be marked as read.
 *                   Shouldn't be greater than currently possible.
 * @param completion Completion handler to get the result or nil
 */
- (void)markAsRead:(SInt64)sequence completion:(nullable VIMessengerCompletion<VIConversationServiceEvent *> *)completion NS_SWIFT_NAME(markAsRead(_:completion:));

@end

NS_ASSUME_NONNULL_END
