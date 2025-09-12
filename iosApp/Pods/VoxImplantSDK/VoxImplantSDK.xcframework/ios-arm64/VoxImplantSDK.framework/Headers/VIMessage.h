/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "VIMessengerCompletion.h"

@class VIConversation;
@class VIMessageEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents message within a conversation.
 *
 * @namespace messaging
 */
@interface VIMessage : NSObject

/**
 * The UUID of the conversation this message belongs to.
 *
 * The message can belong to the one conversation only.
 */
@property(nonatomic, strong, readonly) NSString *conversation;

/**
 * An array of payload objects associated with the message.
 */
@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString *, NSObject *> *> *payload;

/**
 * A text of this message.
 */
@property(nonatomic, strong, readonly) NSString *text;

/**
 * The universally unique identifier (UUID) of the message.
 */
@property(nonatomic, strong, readonly) NSString *uuid;

/**
 * The message sequence number in the conversation.
 */
@property(nonatomic, assign, readonly) SInt64 sequence;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Send text and payload changes to the cloud.
 *
 * The participant that calls this method should have:
 * - the <[VIConversationParticipant canEditMessages]> permission
 *   to update its own messages
 * - the <[VIConversationParticipant canEditAllMessages]> permission
 *   to update other participants' messages
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIMessageEvent> or <VIErrorEvent> in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didEditMessage:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about the message updating via
 * the <[VIMessengerDelegate messenger:didEditMessage:]> event.
 *
 * To be informed about the message updating while being offline, participants can
 * subscribe to the <VIMessengerNotificationEditMessage> messenger push notification.
 *
 * @param text       New text of this message, maximum 5000 characters.
 *                   If nil, message text will not be updated.
 * @param payload    New payload of this message. If nil, message payload will not be updated.
 * @param completion Completion handler to get the result or nil
 */
- (void)update:(nullable NSString *)text payload:(nullable NSArray<NSDictionary<NSString *, NSObject *> *> *)payload completion:(nullable VIMessengerCompletion<VIMessageEvent *> *)completion;

/**
 * Remove the message from the conversation.
 *
 * The participant that calls this method should have:
 * - the <[VIConversationParticipant canRemoveMessages]> permission
 *   to remove its own messages
 * - the <[VIConversationParticipant canRemoveAllMessages]> permission
 *   to remove other participants' messages
 *
 * To get the method call result use one of the following options:
 * 1. Specify the completion parameter to consume the results with
 *    <VIMessageEvent> or <VIErrorEvent>
 *    in case of success/error accordingly.
 * 2. Implement the <[VIMessengerDelegate messenger:didRemoveMessage:]>
 *    and <[VIMessengerDelegate messenger:didReceiveError:]> events.
 *
 * Other parties of the conversation (online participants and logged in clients)
 * can be informed about the message removing via
 * the <[VIMessengerDelegate messenger:didRemoveMessage:]> event.
 *
 * @param completion Completion handler to get the result or nil
 */
- (void)remove:(nullable VIMessengerCompletion<VIMessageEvent *> *)completion NS_SWIFT_NAME(remove(completion:));

@end

NS_ASSUME_NONNULL_END
