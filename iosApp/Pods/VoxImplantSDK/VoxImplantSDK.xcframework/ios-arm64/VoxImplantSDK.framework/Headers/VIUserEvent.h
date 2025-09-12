/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

@class VIUser;

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents messenger events related to users, such as get or edit user.
 *
 * Extends <VIMessengerEvent> which provides service information (IM user id, action, event type).
 *
 * @namespace messaging
 */
@interface VIUserEvent : VIMessengerEvent

/**
 * Instance with the user details.
 */
@property(nonatomic, strong, readonly) VIUser *user;

@end

NS_ASSUME_NONNULL_END
