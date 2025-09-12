/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import "VIVideoSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Flags to set supported camera rotation modes.
 *
 * @namespace hardware
 */
typedef NS_OPTIONS(NSInteger, VISupportedDeviceOrientation) {
    /** Allow portrait. */
            VISupportedDeviceOrientationPortrait = 1 << 0,
    /** Allow portrait upside down. */
            VISupportedDeviceOrientationPortraitUpsideDown = 1 << 1,
    /** Allow Landscape left. */
            VISupportedDeviceOrientationLandscapeLeft = 1 << 2,
    /** Allow landscape right. */
            VISupportedDeviceOrientationLandscapeRight = 1 << 3,
    /** Allow all orientations. */
            VISupportedDeviceOrientationAll = VISupportedDeviceOrientationPortrait | VISupportedDeviceOrientationPortraitUpsideDown | VISupportedDeviceOrientationLandscapeLeft | VISupportedDeviceOrientationLandscapeRight,
};

/**
 * @namespace hardware
 */
@protocol VIVideoPreprocessDelegate <NSObject>

@optional
/**
 * Triggered when new video frame is available for preprocessing.
 *
 * @param pixelBuffer Video frame.
 * @param rotation    Video frame rotation.
 */
- (void)preprocessVideoFrame:(CVPixelBufferRef)pixelBuffer rotation:(VIRotation)rotation;

@end

/**
 * VICameraManager
 *
 * @namespace hardware
 */
@interface VICameraManager : VIVideoSource

/**
 * Direct initialization of this object can produce undesirable consequences.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Obtain Camera manager instance.
 *
 * @return Manager instance.
 */
+ (instancetype)sharedCameraManager;

/**
 * Get list of available capture devices that support video capture.
 *
 * @return List of available capture devices.
 */
- (NSArray<AVCaptureDevice *> *)captureDevices;

/**
 * Get list of formats(resolutions) that are supported by requested device.
 *
 * @param device Capture device to get its formats.
 * @return List of formats.
 */
- (NSArray<AVCaptureDeviceFormat *> *)supportedFormatsForDevice:(AVCaptureDevice *)device;

/**
 * Change video format (resolution) to be sent to remote participant.
 * Default video format 640x480 for video call and 352x288 for conference call.
 *
 * @param format New video format.
 */
- (void)changeCaptureFormat:(AVCaptureDeviceFormat *)format;

/**
 * A video preprocessing delegate.
 */
@property(nonatomic, weak, nullable) id <VIVideoPreprocessDelegate> videoPreprocessDelegate;

/**
 * A Boolean value indicating if back camera should be used.
 */
@property(nonatomic, assign) BOOL useBackCamera;

/**
 * A Boolean value indicating if front camera preview should be mirrored. Defaults to YES.
 */
@property(nonatomic, assign) BOOL shouldMirrorFrontCamera;

/**
 * The property sets supported orientations for phones. Defaults to <VISupportedDeviceOrientationAll>.
 */
@property(nonatomic, assign) VISupportedDeviceOrientation iPhoneOrientationMask;

/**
 * The property sets supported orientations for tablets. Defaults to <VISupportedDeviceOrientationAll>.
 */
@property(nonatomic, assign) VISupportedDeviceOrientation iPadOrientationMask;

/**
 * Sets supported orientation for all devices.
 *
 * @param iPhoneOrientationMask supported orientations for phones. Defaults to <VISupportedDeviceOrientationAll>.
 * @param iPadOrientationMask supported orientations for tablets. Defaults to <VISupportedDeviceOrientationAll>.
 */
- (void)setSupportedDeviceOrientationForIPhone:(VISupportedDeviceOrientation)iPhoneOrientationMask
                                          iPad:(VISupportedDeviceOrientation)iPadOrientationMask
NS_SWIFT_NAME(setSupportedDeviceOrientation(iPhone:iPad:));

@end

NS_ASSUME_NONNULL_END
