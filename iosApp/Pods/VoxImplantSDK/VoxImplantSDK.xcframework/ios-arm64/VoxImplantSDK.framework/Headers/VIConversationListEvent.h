/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents messenger events related to conversation enumeration.
 *
 * Extends <VIMessengerEvent> which provides service information
 * (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VIConversationListEvent : VIMessengerEvent

/**
 * An array of conversations UUIDs.
 */
@property(nonatomic, strong, readonly) NSArray<NSString *> *conversationList;

@end

NS_ASSUME_NONNULL_END
