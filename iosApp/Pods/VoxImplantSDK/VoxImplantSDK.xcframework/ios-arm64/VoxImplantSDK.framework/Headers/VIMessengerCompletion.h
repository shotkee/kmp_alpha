/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class VIErrorEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents a completion handler that is used to get results of
 * methods such as
 * <[VIConversation update:]>,
 * <[VIMessenger getUserByName:completion:]>, etc.
 *
 * A queue on which all events will be received is specified via
 * <[VIClient initWithDelegateQueue:]>.
 *
 * @namespace messaging
 */
@interface VIMessengerCompletion<__covariant ObjectType> : NSObject

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
 - (instancetype)init NS_UNAVAILABLE;

/**
 * Creates completion handler.
 *
 * @param success Invoked when a method call with the specified completion handler is successfully completed.
 *                ObjectType depends on the called method, e.g., it will be <VIUserEvent> if <[VIMessenger getUserByIMId:completion:]>
 *                is called.
 * @param failure Invoked when an error occurred as the method call result
 *                with the specified completion handler.
 *
 * @return        Completion handler
 */
+ (instancetype)success:(void (^)(ObjectType result))success
                failure:(void (^)(VIErrorEvent *errorEvent))failure NS_SWIFT_NAME(init(success:failure:));

@end

NS_ASSUME_NONNULL_END
