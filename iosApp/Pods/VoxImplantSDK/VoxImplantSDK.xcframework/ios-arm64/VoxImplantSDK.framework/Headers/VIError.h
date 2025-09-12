/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSErrorDomain VIErrorDomain NS_STRING_ENUM;
FOUNDATION_EXPORT VIErrorDomain const VIErrorDomainLogin;
FOUNDATION_EXPORT VIErrorDomain const VIErrorDomainCallFail;
FOUNDATION_EXPORT VIErrorDomain const VIErrorDomainCall;
FOUNDATION_EXPORT VIErrorDomain const VIErrorDomainConnectivity;
FOUNDATION_EXPORT VIErrorDomain const VIErrorDomainPushToken;
FOUNDATION_EXPORT VIErrorDomain const VIErrorDomainMessenger;
FOUNDATION_EXPORT VIErrorDomain const VIErrorDomainAudioFile;

/**
 * Login error codes.
 *
 * @namespace client
 */
typedef NS_ERROR_ENUM(VIErrorDomainLogin, VILoginErrorCode) {
    /** Invalid login or password. */
    VILoginErrorCodeInvalidPassword = 401,
    /** Monthly Active Users (MAU) limit is reached. Payment is required. */
    VILoginErrorCodeMAUAccessDenied = 402,
    /** Account frozen. */
    VILoginErrorCodeAccountFrozen = 403,
    /** Invalid username. */
    VILoginErrorCodeInvalidUsername = 404,
    /** Login is failed due to timeout. */
    VILoginErrorCodeTimeout = 408,
    /** Connection to the Voximplant Cloud is closed as a result of <[VIClient disconnect]> method call. */
    VILoginErrorCodeConnectionClosed = 409,
    /** Login is failed due to invalid state. */
    VILoginErrorCodeInvalidState = 491,
    /** Internal error. */
    VILoginErrorCodeInternalError = 500,
    /** Connection to the Voximplant Cloud is closed due to network issues. */
    VILoginErrorCodeNetworkIssues = 503,
    /** Token expired. */
    VILoginErrorCodeTokenExpired = 701,
};

/**
 * Call failure error codes.
 *
 * @namespace call
 */
typedef NS_ERROR_ENUM(VIErrorDomainCallFail, VICallFailErrorCode) {
    /** Insufficient funds. */
    VICallFailErrorCodeInsufficientFunds = 402,
    /** Invalid number. */
    VICallFailErrorCodeInvalidNumber = 404,
    /** Request timeout. */
    VICallFailErrorCodeRequestTimeout = 408,
    /** Connection Closed. */
    VICallFailErrorCodeConnectionClosed = 409,
    /** Destination number is temporary unavailable. */
    VICallFailErrorCodeTemporaryUnavailable = 480,
    /** Destination number is busy. */
    VICallFailErrorCodeNumberBusy = 486,
    /** Request terminated. */
    VICallFailErrorCodeRequestTerminated = 487,
    /** Internal error. */
    VICallFailErrorCodeInternalError = 500,
    /** Service Unavailable. */
    VICallFailErrorCodeServiceUnavailable = 503,
    /** Call was rejected. */
    VICallFailErrorCodeRejected = 603,
};

/**
 * Call error codes.
 *
 * @namespace call
 */
typedef NS_ERROR_ENUM(VIErrorDomainCall, VICallErrorCode) {
    /** Operation is rejected. */
    VICallErrorCodeRejected = 10004,
    /** Operation is not completed in time. */
    VICallErrorCodeTimeout = 10005,
    /** Operation is not permitted while media is on hold. Call <[VICall setHold:completion:]> and repeat operation. */
    VICallErrorCodeMediaIsOnHold = 10007,
    /** The call is already in requested state. */
    VICallErrorCodeAlreadyInThisState = 10008,
    /** Operation is incorrect, f.ex. reject outgoing call */
    VICallErrorCodeIncorrectOperation = 10009,
    /** Internal error occurred */
    VICallErrorCodeInternalError = 10010,
    /** Operation was rejected due to call has ended */
    VICallErrorCodeCallEnded = 10011,
    /** Operation is not supported */
    VICallErrorCodeOperationIsNotSupported = 10012,
    /** Operation cannot be performed due to the call is reconnecting */
    VICallErrorCodeReconnecting = 10013,
};

/**
 * Connectivity error codes.
 *
 * @namespace client
 */
typedef NS_ERROR_ENUM(VIErrorDomainConnectivity, VIConnectivityErrorCode) {
    /** Connectivity check failed. */
    VIConnectivityErrorCodeConnectivityCheckFailed = 10000,
    /** Connection failed. */
    VIConnectivityErrorCodeConnectionFailed = 10001,
};

/**
 * @namespace client
 */
typedef NS_ERROR_ENUM(VIErrorDomainPushToken, VIPushTokenErrorCode) {
    /** Internal error occurred */
    VIPushTokenErrorCodeInternalError = 500,
    /** Operation is not completed in time. */
    VIPushTokenErrorCodeTimeout = 10005,
    /** Connection to the Voximplant Cloud is closed while processing push token registration request. */
    VIPushTokenErrorCodeConnectionClosed = 409,
    /**Push token is invalid, for example nil or empty. */
    VIPushTokenErrorCodeInvalidToken = 10021,
    /** Operation is cancelled due to the maximum number of unprocessed requests is reached. */
    VIPushTokenErrorCodeCancelled = 10022
};

/**
 * Audio file error codes.
 *
 * @namespace hardware
 */
typedef NS_ERROR_ENUM(VIErrorDomainAudioFile, VIAudioFileErrorCode) {
    /** Internal error occurred. */
    VIAudioFileErrorCodeInternal = 10101,
    /** The audio file is already playing. */
    VIAudioFileErrorCodeAlreadyPlaying = 10103,
    /** Audio file failed to start playing due to audio session configuration issues. */
    VIAudioFileErrorCodeFailedToConfigureAudioSession = 10106,
    /** Audio file playing was interrupted by CallKit activation. */
    VIAudioFileErrorCodeCallKitActivated = 10107,
    /** Audio file playing was interrupted by CallKit deactivation. */
    VIAudioFileErrorCodeCallKitDeactivated = 10108,
    /** Audio file playing was interrupted by a third party application. */
    VIAudioFileErrorCodeInterrupted = 10109,
    /** Audio file playing was stopped due to <VIAudioFile> instance is deallocated. */
    VIAudioFileErrorCodeDestroyed = 10110,
};

NS_ASSUME_NONNULL_END
