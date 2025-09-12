/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VIAudioDevice.h"
#import "VIError.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @namespace hardware
 */
@protocol VIAudioManagerDelegate <NSObject>

/**
 * Event is triggered when active audio device or audio device that will be used for a further call is changed.
 *
 * @param audioDevice Activated audio device.
 */
- (void)audioDeviceChanged:(VIAudioDevice *)audioDevice;

/**
 * Event is triggered when audio device can not be selected due to it is not available at this moment.
 *
 * @param audioDevice Failed audio device.
 */
- (void)audioDeviceUnavailable:(VIAudioDevice *)audioDevice;

/**
 * Event is triggered when a new audio device connected or an old audio device disconnected. If an old audio device was not selected before it has been disconnected, this delegate method may be not invoked.
 *
 * Please consider the list of known issues and limitations for <[VIAudioManager availableAudioDevices]>.
 *
 * @param availableAudioDevices List of newly available audio devices.
 */
- (void)audioDevicesListChanged:(NSSet<VIAudioDevice *> *)availableAudioDevices;

@end

/**
 * Interface that may be used to manage audio devices on iOS device.
 *
 * Limitations:
 * - It is not possible to select an VIAudioDeviceTypeReceiver while wired headset is connected.
 * - Wired headsets without a microphone may be recognized and selected as VIAudioDeviceTypeReceiver.
 * - iOS 12 and AirPods: during an active call, VIAudioDeviceTypeReceiver or VIAudioDeviceTypeSpeaker selection may fail if AirPods are used as current active device.
 *
 * @namespace hardware
 */
@interface VIAudioManager : NSObject

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Obtain audio manager instance.
 *
 * @return Audio manager instance.
 */
+ (instancetype)sharedAudioManager;

/**
 * A delegate to monitor audio session route changes.
 */
@property (nonatomic, weak, nullable) id<VIAudioManagerDelegate> delegate;

/**
 * Switch priorities between audio devices of type Receiver and Speaker.
 *
 * If set to NO, Receiver is the default audio device. If set to YES, Speaker becomes the default audio device.
 *
 * The default value is NO.
 *
 * Setting this property does not actually change the selected audio device, but changes the preference of the default audio device.
 *
 * If an audio device was not selected via <[VIAudioManager selectAudioDevice:]> method and there is no priority audio devices such as Bluetooth or wired headset connected to the mobile phone, this property sets the priority between Receiver and Speaker (built-in audio devices).
 *
 * The option is recommended to be used for video calls.
 */
@property(nonatomic, assign) BOOL speakerIsDefault;

/**
 * Select AVAudioSessionMode to be used for a call.
 *
 * AVAudioSessionModeVoiceChat is the default value.
 *
 * AVAudioSessionModeVideoChat may be selected for video calls.
 *
 * Other AVAduioSessionMode values may be incompatible with other AVAudioSession options used for calls and may cause audio issues during a call.
 */
@property(nonatomic) AVAudioSessionMode mode;

/**
 * Changes selection of the current active audio device.
 *
 * There are two cases:
 *
 * 1. Before a call. The method doesn't activate an audio device, it just selects (i.e. points to) the audio device that will be activated.
 *
 * 2. During a call. If the selected audio device is available, the method activates this audio device.
 *
 * Please note that active audio device can be later changed if new device is connected.
 * In this case <[VIAudioManagerDelegate audioDeviceChanged:]> will be triggered to notify about new active device.
 *
 * If the application uses CallKit, you should take into consideration:
 *
 * - If Bluetooth headset is connected, audio routing depends on where a call is answered (from bluetooth headset or from phone screen).
 *   Bluetooth headset will be activated only if a call is answered via Bluetooth headset controls. In other case the audio will be played via Receiver.
 *
 * - Audio is always routed to Bluetooth headset only if user selects "Bluetooth headset" as Call Audio Routing in the phone preferences.
 *
 * - If audio device is selected before CallKit activates the audio session, it is required to reselect this audio device after [[CXProviderDelegate provider:didActivateAudioSession:]](https://developer.apple.com/documentation/callkit/cxproviderdelegate/1833281-provider?language=objc) is called. Otherwise audio routing may be reset to default.
 *
 * Known issues:
 * - It is not possible to select Receiver while a call is on hold and it is reported to CallKit.
 * - It is not possible to select Receiver before a call is connected, if a Blutooth audio device is connected.
 *
 * @param audioDevice Preferred audio device to use.
 */
- (void)selectAudioDevice:(VIAudioDevice *)audioDevice;

/**
 * Returns active audio device during the call or audio device that will be used for a call if there is no calls at this moment.
 *
 * Please note that active audio device can be later changed if new device is connected.
 * In this case <[VIAudioManagerDelegate audioDeviceChanged:]> will be triggered to notify about new active device.
 *
 * @return Currently active audio device.
 */
- (VIAudioDevice *)currentAudioDevice;

/**
 * Returns the list of available audio devices.
 *
 * For Bluetooth devices with Automatic Ear Detection feature (AirPods) please consider the following list of known issues and limitations:
 *
 * - Before a call: if AirPods are connected to the phone, but you are not wearing them, audio device list will be updated and include AirPods on a call start.
 * - Before a call: Bluetooth device may not be detected if AVAudioSession category is different from PlayAndRecord.
 * - During a call: if Bluetooth device is AirPods and they have been put to the case after another device is seleted by <[VIAudioManager selectAudioDevice:]>, available audio devices list is not updated.
 * - During a call: if an active audio device is switched from Bluetooth to another audio device by <[VIAudioManager selectAudioDevice:]> API, Bluetooth device is not removed from the available audio devices list after Bluetooth is turned off on the phone.
 *
 * @return List of currently available audio devices.
 */
- (NSSet<VIAudioDevice *> *)availableAudioDevices;

@end

@interface VIAudioManager (CallKit)
/**
 * Required for the correct CallKit integration only. Otherwise don't use this method.
 *
 * Initializes [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession?language=objc) for use with CallKit integration.
 *
 * Should be called before [[CXProviderDelegate provider:performStartCallAction:]](https://developer.apple.com/documentation/callkit/cxproviderdelegate/1648260-provider?language=objc)
 * and before [[CXProviderDelegate provider:performAnswerCallAction:]](https://developer.apple.com/documentation/callkit/cxproviderdelegate/1648270-provider?language=objc).
 *
 * @param error Error during configuration steps.
 */
- (void)callKitConfigureAudioSession:(NSError * _Nullable *)error;

/**
 * Required for the correct CallKit integration only. Otherwise don't use this method.
 *
 * Restores default [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession?language=objc) initialization routines, MUST be called after the call has ended, i.e. [[CXProvider reportCallWithUUID:endedAtDate:reason:]](https://developer.apple.com/documentation/callkit/cxprovider/1930701-reportcallwithuuid?language=objc) was called.
 */
- (void)callKitReleaseAudioSession;

/**
 * Required for the correct CallKit integration only. Otherwise don't use this method.
 *
 * Starts [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession?language=objc).
 *
 * Should be called in [[CXProviderDelegate provider:didActivateAudioSession:]](https://developer.apple.com/documentation/callkit/cxproviderdelegate/1833281-provider?language=objc).
 */
- (void)callKitStartAudio;

/**
 * Required for the correct CallKit integration only. Otherwise don't use this method.
 *
 * Stops [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession?language=objc).
 *
 * Should be called in [[CXProviderDelegate provider:didDeactivateAudioSession:]](https://developer.apple.com/documentation/callkit/cxproviderdelegate/1833280-provider?language=objc).
 */
- (void)callKitStopAudio;

@end

NS_ASSUME_NONNULL_END
