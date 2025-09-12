#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Describes type of feature filter.
 */
typedef NS_ENUM(NSUInteger, YMKSublayerFeatureFilterType) {
    /**
     * Excluding filter
     */
    YMKSublayerFeatureFilterTypeExclude,
    /**
     * Including filter
     */
    YMKSublayerFeatureFilterTypeInclude
};
