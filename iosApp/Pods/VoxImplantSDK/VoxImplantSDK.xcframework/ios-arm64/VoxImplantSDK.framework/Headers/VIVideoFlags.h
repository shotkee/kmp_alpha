/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Specifies video direction for call.
 *
 * @namespace call
 */
@interface VIVideoFlags : NSObject

/**
 * Specify if video receiving is enabled for a call.
 */
@property (assign, nonatomic) BOOL receiveVideo;

/**
 * Specify if video sending is enabled for a call.
 */
@property (assign, nonatomic) BOOL sendVideo;

/**
 * Default <VIVideoFlags> with receiveVideo and sendVideo set to YES.
 *
 * @return instance
 */
+ (instancetype)defaultVideoFlags NS_SWIFT_NAME(videoFlags());

/**
 * Creates <VIVideoFlags> instance with specified video directions.
 *
 * @param receiveVideo Specify if video receiving is enabled for a call.
 * @param sendVideo    Specify if video sending is enabled for a call.
 * @return instance
 */
+ (instancetype)videoFlagsWithReceiveVideo:(BOOL)receiveVideo sendVideo:(BOOL)sendVideo NS_SWIFT_NAME(videoFlags(receiveVideo:sendVideo:));

@end

NS_ASSUME_NONNULL_END
