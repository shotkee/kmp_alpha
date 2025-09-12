#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Geo object metadata which is needed to select object.
 */
YRT_EXPORT @interface YMKGeoObjectSelectionMetadata : NSObject

/**
 * Object ID.
 */
@property (nonatomic, readonly, nonnull) NSString *id;

/**
 * Layer ID.
 */
@property (nonatomic, readonly, nonnull) NSString *layerId;


+ (nonnull YMKGeoObjectSelectionMetadata *)geoObjectSelectionMetadataWithId:(nonnull NSString *)id
                                                                    layerId:(nonnull NSString *)layerId;


@end
