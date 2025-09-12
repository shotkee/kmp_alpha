/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents messenger events such as typing, markAsRead.
 *
 * Extends <VIMessengerEvent> which provides service information
 * (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VIConversationServiceEvent : VIMessengerEvent

/**
 * The conversation UUID associated with this event.
 */
@property(nonatomic, strong, readonly) NSString *conversationUUID;

/**
 * The sequence number of the event that was marked as read by the user initiated this event.
 * Only available for <VIMessengerEventTypeIsRead>.
 */
@property(nonatomic, assign, readonly) SInt64 sequence;

@end

NS_ASSUME_NONNULL_END
