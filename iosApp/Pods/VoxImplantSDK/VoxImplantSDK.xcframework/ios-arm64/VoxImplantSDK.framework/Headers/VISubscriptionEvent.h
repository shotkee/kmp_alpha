/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents the messenger events related to subscriptions.
 *
 * Extends <VIMessengerEvent> which provides service information (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VISubscriptionEvent : VIMessengerEvent

/**
 *  An array of the IM user identifiers of the current (un)subscription.
 */
@property(nonatomic, strong, readonly) NSArray<NSNumber *> *users;

@end

NS_ASSUME_NONNULL_END
