#import <YandexMapsMobile/YMKGeoObject.h>
#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YRTCollection.h>
#import <YandexMapsMobile/YRTExport.h>

@class YMKGeoObjectCollectionItem;

/**
 * A collection of geo objects. Allows you to group geo objects for
 * adding them to the map, setting options, etc. Collections are geo
 * objects too.
 */
YRT_EXPORT @interface YMKGeoObjectCollection : NSObject

/**
 * The bounds around the collection of objects.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, readonly, nullable) YMKBoundingBox *boundingBox;

/**
 * The metadata for the objects.
 */
@property (nonatomic, readonly, nonnull) YRTCollection *metadataContainer;

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSArray<YMKGeoObjectCollectionItem *> *children;


+ (nonnull YMKGeoObjectCollection *)geoObjectCollectionWithBoundingBox:(nullable YMKBoundingBox *)boundingBox
                                                     metadataContainer:(nonnull YRTCollection *)metadataContainer
                                                              children:(nonnull NSArray<YMKGeoObjectCollectionItem *> *)children;


@end

/**
 * The geo objects in the collection.
 */
YRT_EXPORT @interface YMKGeoObjectCollectionItem : NSObject

@property (nonatomic, readonly, nullable) YMKGeoObject *obj;

@property (nonatomic, readonly, nullable) YMKGeoObjectCollection *collection;

+ (nonnull YMKGeoObjectCollectionItem *)itemWithObj:(nonnull YMKGeoObject *)obj;

+ (nonnull YMKGeoObjectCollectionItem *)itemWithCollection:(nonnull YMKGeoObjectCollection *)collection;

@end

