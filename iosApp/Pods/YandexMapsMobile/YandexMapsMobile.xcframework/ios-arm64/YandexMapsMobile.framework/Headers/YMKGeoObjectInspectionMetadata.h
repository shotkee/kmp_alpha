#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * Undocumented
 */
typedef NS_ENUM(NSUInteger, YMKGeoObjectInspectionMetadataObjectType) {
    /**
     * Undocumented
     */
    YMKGeoObjectInspectionMetadataObjectTypePoint,
    /**
     * Undocumented
     */
    YMKGeoObjectInspectionMetadataObjectTypePolyline,
    /**
     * Undocumented
     */
    YMKGeoObjectInspectionMetadataObjectTypePolygon,
    /**
     * Undocumented
     */
    YMKGeoObjectInspectionMetadataObjectTypeCircle
};

/**
 * Metadata type added to all objects returned by Map.visibleObjects
 */
YRT_EXPORT @interface YMKGeoObjectInspectionMetadata : NSObject

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSString *layerId;

/**
 * Undocumented
 */
@property (nonatomic, readonly) YMKGeoObjectInspectionMetadataObjectType objectType;


+ (nonnull YMKGeoObjectInspectionMetadata *)geoObjectInspectionMetadataWithLayerId:(nonnull NSString *)layerId
                                                                        objectType:( YMKGeoObjectInspectionMetadataObjectType)objectType;


@end
