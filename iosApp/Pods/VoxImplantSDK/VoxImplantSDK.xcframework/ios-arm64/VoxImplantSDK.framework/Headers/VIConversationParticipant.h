/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class that represents a participant of the conversation.
 *
 * In order to apply changes made by setters, you have to call one of the following methods:
 * - <[VIMessenger createConversation:completion:]>
 * - <[VIConversation addParticipants:completion:]>
 * - <[VIConversation editParticipants:completion:]>
 *
 * The default permissions for all participants are: write / edit / remove their own messages.
 *
 * The creator of any conversation by default:
 * - is the owner (<[VIConversationParticipant owner]> is YES)
 * - can edit / remove other participants' messages
 * - can manage other participants
 *
 * @namespace messaging
 */
@interface VIConversationParticipant : NSObject

/**
 * The IM user id.
 */
@property(nonatomic, strong, readonly) NSNumber *imUserId;

/**
 * A Boolean value that determines whether the conversation participant
 * can send messages to the conversation.
 *
 * Once a participant is created, it's YES by default.
 *
 * It could be changed only if the user has
 * the <[VIConversationParticipant canManageParticipants]> permission.
 *
 * Note that a value change doesn't apply changes by itself; there are appropriate methods
 * for applying:
 * - <[VIConversation editParticipants:completion:]> for an existing conversation
 * - <[VIMessenger createConversation:completion:]> for a new conversation
 */
@property(nonatomic, assign) BOOL canWrite;

/**
 * A Boolean value that determines whether the conversation participant
 * can edit its own messages.
 *
 * Once a participant is created, it's YES by default.
 *
 * It could be changed only if the user has
 * the <[VIConversationParticipant canManageParticipants]> permission.
 *
 * If the user that calls this method has both canManageParticipants and isOwner permissions,
 * it can edit other owners.
 *
 * Note that a value change doesn't apply changes by itself; there are appropriate methods
 * for applying:
 * - <[VIConversation editParticipants:completion:]> for an existing conversation
 * - <[VIMessenger createConversation:completion:]> for a new conversation
 */
@property(nonatomic, assign) BOOL canEditMessages;

/**
 * A Boolean value that determines whether the conversation participant
 * can remove its own messages.
 *
 * Once a participant is created, it's YES by default.
 *
 * It could be changed only if the user has
 * the <[VIConversationParticipant canManageParticipants]> permission.
 *
 * If the user that calls this method has both canManageParticipants and isOwner permissions,
 * it can edit other owners.
 *
 * Note that a value change doesn't apply changes by itself; there are appropriate methods
 * for applying:
 * - <[VIConversation editParticipants:completion:]> for an existing conversation
 * - <[VIMessenger createConversation:completion:]> for a new conversation
 */
@property(nonatomic, assign) BOOL canRemoveMessages;

/**
 * A Boolean value that determines whether the conversation participant
 * can edit messages other than its own.
 *
 * It could be changed only if the user has
 * the <[VIConversationParticipant canManageParticipants]> permission.
 *
 * If the user that calls this method has both canManageParticipants and isOwner permissions,
 * it can edit other owners.
 *
 * Note that a value change doesn't apply changes by itself; there are appropriate methods
 * for applying:
 * - <[VIConversation editParticipants:completion:]> for an existing conversation
 * - <[VIMessenger createConversation:completion:]> for a new conversation
 */
@property(nonatomic, assign) BOOL canEditAllMessages;

/**
 * A Boolean value that determines whether the conversation participant
 * can remove messages other than its own.
 *
 * It could be changed only if the user has
 * the <[VIConversationParticipant canManageParticipants]> permission.
 *
 * If the user that calls this method has both canManageParticipants and isOwner permissions,
 * it can edit other owners.
 *
 * Note that a value change doesn't apply changes by itself; there are appropriate methods
 * for applying:
 * - <[VIConversation editParticipants:completion:]> for an existing conversation
 * - <[VIMessenger createConversation:completion:]> for a new conversation
 */
@property(nonatomic, assign) BOOL canRemoveAllMessages;

/**
 * A Boolean value that determines whether the conversation participant
 * can manage other participants in the conversation:
 * - add / remove / edit permissions
 * - add / remove participants
 *
 * If YES and isOwner is YES, the participant can manage other owners.
 *
 * It could be changed only if the user has
 * the <[VIConversationParticipant canManageParticipants]> permission.
 *
 * If the user that calls this method has both canManageParticipants and isOwner permissions,
 * it can edit other owners.
 *
 * Note that a value change doesn't apply changes by itself; there are appropriate methods
 * for applying:
 * - <[VIConversation editParticipants:completion:]> for an existing conversation
 * - <[VIMessenger createConversation:completion:]> for a new conversation
 */
@property(nonatomic, assign) BOOL canManageParticipants;

/**
 * A Boolean value that determines whether the
 * conversation participant is an owner.
 *
 * There could be more than one owner in the conversation.
 *
 * If YES, the participant can edit the conversation. If YES and canManageParticipants is
 * YES, the participant can manage other owners.
 *
 * It could be changed only if the user has
 * the <[VIConversationParticipant canManageParticipants]> and <[VIConversationParticipant owner]> permissions.
 *
 * Note that a value change doesn't apply changes by itself; there are appropriate methods
 * for applying:
 * - <[VIConversation editParticipants:completion:]> for an existing conversation
 * - <[VIMessenger createConversation:completion:]> for a new conversation
 */
@property(nonatomic, assign, getter=isOwner) BOOL owner;

/**
 * Sequence of the event that was last marked as read or 0 if the participant didn't mark
 * events as read.
 *
 * Participants mark events as read via <[VIConversation markAsRead:completion:]>.
 */
@property(nonatomic, assign, readonly) SInt64 lastReadEventSequence;

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Create a new participant with default permissions.
 *
 * Use <[VIConversationConfig participants]>
 * or <[VIConversation addParticipants:completion:]>
 * to add participants to the conversation.
 *
 * @param imUserId IM User id. Can be retrieved from <[VIUser imId]>
 */
- (instancetype)initWithIMUserId:(NSNumber *)imUserId NS_DESIGNATED_INITIALIZER;

/**
 * Create a new participant with default permissions.
 *
 * Use <[VIConversationConfig participants]>
 * or <[VIConversation addParticipants:completion:]>
 * to add participants to the conversation.
 *
 * @param imUserId IM User id. Can be retrieved from <[VIUser imId]>
 */
+ (instancetype)forIMUserId:(NSNumber *)imUserId NS_SWIFT_UNAVAILABLE("Use VIConversationParticipant(imUserId:) instead.");

@end

NS_ASSUME_NONNULL_END
