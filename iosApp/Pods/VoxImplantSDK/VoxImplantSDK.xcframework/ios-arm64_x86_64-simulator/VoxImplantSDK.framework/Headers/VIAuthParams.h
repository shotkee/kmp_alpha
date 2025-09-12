/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Authentication parameters that may be used for login with access token.
 *
 * @namespace client
 */
@interface VIAuthParams : NSObject

/**
 * Access token that can be used this token before accessExpire.
 */
@property(strong, nonatomic, readonly) NSString *accessToken;

/**
 * Time in seconds to access token expire.
 */
@property(assign, nonatomic, readonly) NSTimeInterval accessExpire;

/**
 * Refresh token that can be used one time before refreshExpire.
 */
@property(strong, nonatomic, readonly) NSString *refreshToken;

/**
 * Time in seconds to refresh token expire.
 */
@property(assign, nonatomic, readonly) NSTimeInterval refreshExpire;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
