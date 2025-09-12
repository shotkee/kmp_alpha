/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents the messenger events for the following methods call result:
 * - <[VIConversation retransmitEventsFrom:to:completion:]>
 * - <[VIConversation retransmitEventsFrom:count:completion:]>
 * - <[VIConversation retransmitEventsTo:count:completion:]>
 *
 * Extends <VIMessengerEvent> which provides service information (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VIRetransmitEvent : VIMessengerEvent

/**
 * An array of event objects that were retransmitted.
 */
@property(nonatomic, strong, readonly) NSArray<VIMessengerEvent *> *events;

/**
 * The event sequence number from which the events were retransmitted.
 */
@property(nonatomic, assign, readonly) SInt64 fromSequence;

/**
 * The event sequence number to which the events were retransmitted.
 */
@property(nonatomic, assign, readonly) SInt64 toSequence;

@end

NS_ASSUME_NONNULL_END
