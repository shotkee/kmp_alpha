/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VIMessenger.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents user information. Voximplant users are created via
 * [the Voximplant control panel](https://manage.voximplant.com/#addUser)
 * or
 * [HTTP API](/docs/references/httpapi/managing_users#adduser).
 *
 * @namespace messaging
 */
@interface VIUser : NSObject

/**
 * An array of UUIDs of the conversations that the user currently belongs to.
 *
 * Can be empty array if user doesn't belong to any conversation or nil if this property is accessed
 * **not** for the current user.
 */
@property(nonatomic, strong, readonly, nullable) NSArray<NSString *> *conversationList;

/**
 * An array of UUIDs for the conversations that:
 * - the user belonged to, but currently is not participating in
 * - are not removed
 *
 * Can be empty array if user didn't leave any conversation or nil if this property is accessed
 * **not** for the current user.
 * */
@property(nonatomic, strong, readonly, nullable) NSArray<NSString *> *leaveConversationList;

/**
 * The Voximplant user identifier, for example 'username@appname.accname'.
 */
@property(nonatomic, strong, readonly) NSString *name;

/**
 * The IM unique id that is used to identify users in events and
 * specify in user-related methods.
 */
@property(nonatomic, strong, readonly) NSNumber *imId;

/**
 * The user's display name which is specified during user creation via
 * [the Voximplant control panel](https://manage.voximplant.com/#addUser)
 * or
 * [HTTP API](/docs/references/httpapi/managing_users#adduser).
 *
 * The display name is available to all users.
 */
@property(nonatomic, strong, readonly) NSString *displayName;

/**
 * The specified user's public custom data available to all users.
 *
 * A custom data can be set via the
 * <[VIMessenger editUserWithCustomData:privateCustomData:completion:]> method.
 */
@property(nonatomic, strong, readonly) NSDictionary<NSString *, NSObject *> *customData;

/**
 * A private custom data available only to the current user.
 *
 * Value of this property is nil if this property is accessed
 * **not** for the current user.
 */
@property(nonatomic, strong, readonly, nullable) NSDictionary<NSString *, NSObject *> *privateCustomData;

/**
 * An array of messenger notifications that the current user is subscribed to.
 *
 * Note that if the property is accessed **not** for the current user, the result will be nil.
 */
@property(nonatomic, strong, readonly, nullable) NSArray<VIMessengerNotification> *notifications;

/**
 * A Boolean value that determines whether the user is deleted or not.
 */
@property(nonatomic, assign, readonly, getter=isDeleted) BOOL deleted;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
