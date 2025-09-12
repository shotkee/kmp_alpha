/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class VIConversationParticipant;

NS_ASSUME_NONNULL_BEGIN

/**
 * Configuration either to create a new conversation or restore a previously created conversation:
 * - <[VIMessenger createConversation:completion:]>
 * - <[VIMessenger recreateConversation:uuid:lastSequence:lastUpdateTime:createdTime:]>
 *
 * @namespace messaging
 */
@interface VIConversationConfig : NSObject
/**
 * A conversation title.
 *
 * It can be later changed via <[VIConversation title]>.
 */
@property(nonatomic, copy, nullable) NSString *title;

/**
 * Specify a custom data of the conversation (up to 5kb).
 *
 * The custom data can be later changed via <[VIConversation customData]>.
 */
@property(nonatomic, copy) NSDictionary<NSString *, NSObject *> *customData;

/**
 * A conversation participants.
 *
 * The participants array can be later changed via:
 * - <[VIConversation addParticipants:completion:]>
 * - <[VIConversation removeParticipants:completion:]>
 */
@property(nonatomic, copy) NSArray<VIConversationParticipant *> *participants;

/**
 * A Boolean value that determines whether the conversation is direct.
 *
 * There can be only 2 participants in a direct conversation which is unique and the
 * only one for these participants. There can't be more than 1 direct conversation for
 * the same 2 users.
 *
 * If one of these users tries to create
 * a new direct conversation with the same participant via
 * <[VIMessenger createConversation:completion:]>,
 * the method will return the UUID of the already existing direct conversation.
 *
 * A direct conversation can't be uber and/or public.
 */
@property(nonatomic, assign, getter=isDirect) BOOL direct;

/**
 * A Boolean value that determines whether the conversation is public.
 *
 * It can be later changed via <[VIConversation publicJoin]>.
 *
 * If true, any user can join the conversation via
 * <[VIMessenger joinConversation:completion:]> by specifying
 * its UUID. Use the <[VIMessenger getPublicConversations:]>
 * method to retrieve all public conversations' UUIDs.
 *
 * A public conversation can't be direct.
 */
@property(nonatomic, assign, getter=isPublicJoin) BOOL publicJoin;

/**
 * A Boolean value that determines whether the conversation is uber.
 *
 * Users in a uber conversation will not be able to retrieve messages that were posted to
 * the conversation after they quit.
 *
 * A uber conversation can't be direct.
 */
@property(nonatomic, assign, getter=isUber) BOOL uber;

@end

NS_ASSUME_NONNULL_END
