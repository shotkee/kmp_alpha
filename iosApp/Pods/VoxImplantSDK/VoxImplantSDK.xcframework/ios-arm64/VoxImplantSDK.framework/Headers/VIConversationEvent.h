/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

@class VIConversation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents messenger events related to conversations such as
 * create, edit, remove, etc.
 *
 * Extends <VIMessengerEvent> which provides service information
 * (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VIConversationEvent : VIMessengerEvent

/**
 * Instance with the conversation details.
 */
@property(nonatomic, strong, readonly) VIConversation *conversation;

/**
 * The sequence number of this event.
 */
@property (nonatomic, assign, readonly) SInt64 sequence;

/**
 * A UNIX timestamp (seconds) that specifies the time the conversation event was provoked.
 */
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
