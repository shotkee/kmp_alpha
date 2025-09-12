/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents the messenger events related to user status changes.
 *
 * Extends <VIMessengerEvent> which provides service information (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VIStatusEvent : VIMessengerEvent

/**
 * A Boolean value that determines the user presence status.
 */
@property(nonatomic, assign, readonly, getter=isOnline) BOOL online;

@end

NS_ASSUME_NONNULL_END
