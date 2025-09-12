#import <YandexMapsMobile/YRTError.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Server responded in unexpected way: unparsable content, wrong content
 * or unexpected HTTP code.
 */
YRT_EXPORT @interface YRTRemoteError : YRTError

@end

/**
 * Client request is invalid (server returned the 400 'Bad Request'
 * response).
 */
YRT_EXPORT @interface YRTBadRequestError : YRTRemoteError

@end

/**
 * Requested object has not been found. Most likely, your link is
 * outdated or the object has been deleted.
 */
YRT_EXPORT @interface YRTNotFoundError : YRTRemoteError

@end

/**
 * Request entity is too large.
 */
YRT_EXPORT @interface YRTRequestEntityTooLargeError : YRTRemoteError

@end

/**
 * You are not allowed to access the requested object.
 */
YRT_EXPORT @interface YRTForbiddenError : YRTRemoteError

@end

/**
 * You do not have a valid MapKit API key.
 */
YRT_EXPORT @interface YRTUnauthorizedError : YRTRemoteError

@end

/**
 * Failed to retrieve data due to network instability.
 */
YRT_EXPORT @interface YRTNetworkError : YRTError

@end
