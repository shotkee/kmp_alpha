/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import "VIMessengerEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents messenger error events.
 *
 * Extends <VIMessengerEvent> which provides service information
 * (action, event type).
 *
 * Error events always invoked on a client where messaging methods are called.
 *
 * Error codes and their descriptions:
 *  - 0 - Something went wrong. Please check your input or required parameters.
 *  - 1 - Transport message structure is wrong.
 *  - 2 - Event name is unknown.
 *  - 3 - User is not authorized.
 *  - 8 - Conversation does not exist.
 *  - 10 - Message with this UUID does not exist in the conversation.
 *  - 11 - Message with this UUID is deleted from the conversation.
 *  - 12 - ACL error.
 *  - 13 - User is already in the participants list.
 *  - 15 - Public join is not available for this conversation.
 *  - 16 - Conversation with this UUID is deleted.
 *  - 18 - User validation error.
 *  - 19 - User is not in the participants list.
 *  - 21 - Number of requested objects is 0 or larger than allowed by the service.
 *  - 22 - Number of requested objects is larger than allowed by the service.
 *  - 23 - Message size exceeds the limit of 5000 symbols.
 *  - 24 - The 'seq' parameter value is greater than currently possible.
 *  - 25 - User is not found.
 *  - 26 - The notification event is incorrect.
 *  - 28 - The 'from' field value is greater than the 'to' field value.
 *  - 30 - IM service is not available. Try again later.
 *  - 32 - N messages per second limit reached. Please try again later.
 *  - 33 - N messages per minute limit reached. Please try again later.
 *  - 34 - Direct conversation cannot be public or uber.
 *  - 35 - Direct conversation is allowed between two users only.
 *  - 36 - Passing the 'eventsFrom', 'eventsTo' and 'count' parameters simultaneously is not allowed. You should use only two of these parameters.
 *  - 37 - Adding participant to direct conversation is not allowed.
 *  - 38 - Removing participant from direct conversation is not allowed.
 *  - 39 - Joining direct conversation is not allowed.
 *  - 40 - Leaving direct conversation is not allowed.
 *  - 41 - Specify at least two parameters: eventsFrom, eventsTo, count.
 *  - 500 - Internal error.
 *  - 10000 - Method calls within 10s interval from the last call are discarded.
 *  - 10001 - Invalid argument(s). | Message text exceeds the length limit.
 *  - 10002 - Response timeout.
 *  - 10003 - Client is not logged in.
 *  - 10004 - Failed to process response.
 *
 *  @namespace messaging
 */
@interface VIErrorEvent : VIMessengerEvent

/**
 * A error code.
 */
@property(nonatomic, assign, readonly) NSInteger errorCode;

/**
 * A error description.
 */
@property(nonatomic, strong, readonly) NSString *errorDescription;

@end

NS_ASSUME_NONNULL_END
