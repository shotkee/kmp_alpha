/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import <VoxImplantSDK/VIClient.h>
#import <VoxImplantSDK/VICall.h>
#import <VoxImplantSDK/VIEndpoint.h>
#import <VoxImplantSDK/VIAudioManager.h>
#import <VoxImplantSDK/VIAudioStream.h>
#import <VoxImplantSDK/VIVideoSource.h>
#import <VoxImplantSDK/VICameraManager.h>
#import <VoxImplantSDK/VIVideoRenderer.h>
#import <VoxImplantSDK/VIVideoRendererView.h>
#import <VoxImplantSDK/VIVideoStream.h>
#import <VoxImplantSDK/VICallStats.h>
#import <VoxImplantSDK/VIOutboundAudioStats.h>
#import <VoxImplantSDK/VIOutboundVideoStats.h>
#import <VoxImplantSDK/VIVideoStreamLayerStats.h>
#import <VoxImplantSDK/VIEndpointStats.h>
#import <VoxImplantSDK/VIInboundAudioStats.h>
#import <VoxImplantSDK/VIInboundVideoStats.h>
#import <VoxImplantSDK/VICallSettings.h>
#import <VoxImplantSDK/VIVideoFlags.h>
#import <VoxImplantSDK/VIQualityIssueDelegate.h>
#import <VoxImplantSDK/VIError.h>
#import <VoxImplantSDK/VIAuthParams.h>
#import <VoxImplantSDK/VIAudioFile.h>
#import <VoxImplantSDK/VILocalAudioStream.h>
#import <VoxImplantSDK/VIRemoteAudioStream.h>
#import <VoxImplantSDK/VILocalVideoStream.h>
#import <VoxImplantSDK/VIRemoteVideoStream.h>

// Messenger
#import <VoxImplantSDK/VIConversation.h>
#import <VoxImplantSDK/VIConversationConfig.h>
#import <VoxImplantSDK/VIConversationEvent.h>
#import <VoxImplantSDK/VIConversationListEvent.h>
#import <VoxImplantSDK/VIConversationParticipant.h>
#import <VoxImplantSDK/VIConversationServiceEvent.h>
#import <VoxImplantSDK/VIErrorEvent.h>
#import <VoxImplantSDK/VIMessage.h>
#import <VoxImplantSDK/VIMessageEvent.h>
#import <VoxImplantSDK/VIMessenger.h>
#import <VoxImplantSDK/VIMessengerCompletion.h>
#import <VoxImplantSDK/VIMessengerEvent.h>
#import <VoxImplantSDK/VIMessengerPushNotificationProcessing.h>
#import <VoxImplantSDK/VIRetransmitEvent.h>
#import <VoxImplantSDK/VIStatusEvent.h>
#import <VoxImplantSDK/VISubscriptionEvent.h>
#import <VoxImplantSDK/VIUser.h>
#import <VoxImplantSDK/VIUserEvent.h>

FOUNDATION_EXPORT double VoxImplantSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char VoxImplantSDKVersionString[];
