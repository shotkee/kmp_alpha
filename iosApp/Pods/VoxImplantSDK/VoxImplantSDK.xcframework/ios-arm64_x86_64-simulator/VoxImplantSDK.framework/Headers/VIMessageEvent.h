/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

@class VIMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents messenger events related to messages (send, update, remove).
 *
 * Extends <VIMessengerEvent> which provides service information
 * (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VIMessageEvent : VIMessengerEvent

/**
 * Instance with the message information.
 */
@property(nonatomic, strong, readonly) VIMessage *message;

/**
 * The sequence number for this event.
 */
@property(nonatomic, assign, readonly) SInt64 sequence;

/**
 * A UNIX timestamp (seconds) that specifies the time the message event was provoked.
 */
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
