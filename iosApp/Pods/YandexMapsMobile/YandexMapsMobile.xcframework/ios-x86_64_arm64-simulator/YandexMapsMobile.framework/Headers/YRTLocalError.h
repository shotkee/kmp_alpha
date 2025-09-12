#import <YandexMapsMobile/YRTError.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Local error has occurred.
 */
YRT_EXPORT @interface YRTLocalError : YRTError

@end

/**
 * Disk is full.
 */
YRT_EXPORT @interface YRTDiskFullError : YRTLocalError

@end

/**
 * Disk is corrupted.
 */
YRT_EXPORT @interface YRTDiskCorruptError : YRTLocalError

@end

/**
 * The application does not have the required write permissions.
 */
YRT_EXPORT @interface YRTDiskWriteAccessError : YRTDiskCorruptError

@end
