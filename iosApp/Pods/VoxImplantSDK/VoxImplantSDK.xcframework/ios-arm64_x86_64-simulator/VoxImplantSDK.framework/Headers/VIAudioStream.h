/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface that represents audio streams.
 *
 * @namespace call
 */
@interface VIAudioStream : NSObject

/**
 * The audio stream id.
 */
@property(nonatomic, strong, readonly) NSString *streamId;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

@end



NS_ASSUME_NONNULL_END
