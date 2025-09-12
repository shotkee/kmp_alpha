/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Enum that represents types of messenger events.
 *
 * @namespace messaging
 */
typedef NSString *VIMessengerEventType NS_STRING_ENUM;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeUnknown;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeCreateConversation;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeEditConversation;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeEditMessage;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeEditUser;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeError;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeGetConversation;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeGetPublicConversations;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeGetSubscriptionList;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeGetUser;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeIsRead;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeRemoveConversation;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeRemoveMessage;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeRetransmitEvents;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeSendMessage;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeSetStatus;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeSubscribe;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeTyping;
FOUNDATION_EXPORT VIMessengerEventType const VIMessengerEventTypeUnsubscribe;

/**
 * Enum that represents actions that trigger messenger events. Each action is the reason
 * for every triggered event.
 *
 * For example, when the <[VIMessengerDelegate messenger:didEditConversation:]>
 * event is invoked,
 * users can inspect the exact reason of it via <[VIMessengerEvent action]>.
 * In case of editing a conversation, it will be one of the following:
 * - <VIMessengerActionAddParticipants>
 * - <VIMessengerActionEditParticipants>
 * - <VIMessengerActionRemoveParticipants>
 * - <VIMessengerActionEditConversation>
 * - <VIMessengerActionJoinConversation>
 * - <VIMessengerActionLeaveConversation>
 *
 * @namespace messaging
 */
typedef NSString *VIMessengerAction NS_STRING_ENUM;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionUnknown;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionAddParticipants;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionCreateConversation;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionEditConversation;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionEditMessage;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionEditParticipants;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionEditUser;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionGetConversation;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionGetConversations;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionGetSubscriptionList;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionGetPublicConversations;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionGetUser;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionGetUsers;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionIsRead;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionJoinConversation;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionLeaveConversation;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionManageNotifications;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionRemoveConversation;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionRemoveMessage;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionRemoveParticipants;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionRetransmitEvents;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionSendMessage;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionSetStatus;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionSubscribe;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionTyping;
FOUNDATION_EXPORT VIMessengerAction const VIMessengerActionUnsubscribe;

/**
 * Base interface that represents all messenger events provided via <VIMessengerDelegate>
 * or <VIMessengerCompletion>.
 *
 * @namespace messaging
 */
@interface VIMessengerEvent : NSObject

/**
 * The messenger event type.
 */
@property(nonatomic, strong, readonly) VIMessengerEventType eventType;

/**
 * The action that triggered this event.
 */
@property(nonatomic, strong, readonly) VIMessengerAction action;

/**
 * The Voximplant IM id for the user that initiated the event.
 *
 * Note that IM user id is always nil for the <VIErrorEvent> events.
 */
@property(nonatomic, strong, readonly, nullable) NSNumber *imUserId;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
