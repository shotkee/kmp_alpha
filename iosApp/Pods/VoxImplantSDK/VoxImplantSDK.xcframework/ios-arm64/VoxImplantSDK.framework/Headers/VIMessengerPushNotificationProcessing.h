/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class VIMessengerEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Helper to process incoming Voximplant messenger push notifications.
 *
 * Note that this interface doesn't serve VoIP push notifications.
 *
 * The interface serves notifications of the <VIMessengerNotification> types;
 * use the <[VIMessenger managePushNotifications:completion:]> method
 * to subscribe to notifications.
 *
 * @namespace messaging
 */
@interface VIMessengerPushNotificationProcessing : NSObject

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Process an incoming Voximplant messenger push notification and return the appropriate messenger
 * event object (<VIMessageEvent>) extended from <VIMessengerEvent>.
 *
 * @param notification Incoming push notification that comes from [[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:]](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application?language=objc).
 * @return             Event object or nil if the notification is not a Voximplant messenger push notification.
 */
+ (nullable VIMessengerEvent *)processPushNotification:(NSDictionary *)notification;

@end

NS_ASSUME_NONNULL_END
