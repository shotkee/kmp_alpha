#import <YandexMapsMobile/YMKAnimation.h>
#import <YandexMapsMobile/YMKGeoObject.h>
#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKImagesImageUrlProvider.h>
#import <YandexMapsMobile/YMKInertiaMoveListener.h>
#import <YandexMapsMobile/YMKLayer.h>
#import <YandexMapsMobile/YMKLayerOptions.h>
#import <YandexMapsMobile/YMKLayersGeoObjectTapListener.h>
#import <YandexMapsMobile/YMKLogo.h>
#import <YandexMapsMobile/YMKMapCameraListener.h>
#import <YandexMapsMobile/YMKMapInputListener.h>
#import <YandexMapsMobile/YMKMapLoadedListener.h>
#import <YandexMapsMobile/YMKMapMode.h>
#import <YandexMapsMobile/YMKMapType.h>
#import <YandexMapsMobile/YMKProjection.h>
#import <YandexMapsMobile/YMKScreenTypes.h>
#import <YandexMapsMobile/YMKTileProvider.h>
#import <YandexMapsMobile/YMKTilesUrlProvider.h>
#import <YandexMapsMobile/YMKZoomRange.h>
#import <YandexMapsMobile/YRTExport.h>

#import <UIKit/UIKit.h>

@class YMKCameraPosition;
@class YMKIconSet;
@class YMKMapObjectCollection;
@class YMKSublayerManager;
@class YMKVisibleRegion;

/**
 * Undocumented
 */
typedef void(^YMKMapCameraCallback)(
    BOOL completed);

/**
 * The object that is used to interact with the map.
 */
YRT_EXPORT @interface YMKMap : NSObject
/**
 * @return Current camera position. Target position must be within
 * latitude [-90, 90] and longitude [-180, 180].
 */
@property (nonatomic, readonly, nonnull) YMKCameraPosition *cameraPosition;

/**
 * @deprecated Use general cameraPosition method for any Geometry
 * instead. Calculates the camera position that projects the specified
 * area into the current focusRect, or the full view if the focusRect is
 * not set.
 */
- (nonnull YMKCameraPosition *)cameraPositionWithBoundingBox:(nonnull YMKBoundingBox *)boundingBox;

/**
 * @deprecated Use general cameraPosition method for any Geometry
 * instead. Calculates the camera position that projects the specified
 * area into the custom focusRect. If focus rect is not provided,
 * current focus rect is used.
 */
- (nonnull YMKCameraPosition *)cameraPositionWithBoundingBox:(nonnull YMKBoundingBox *)boundingBox
                                                   focusRect:(nonnull YMKScreenRect *)focusRect;

/**
 * @return Camera position that projects the specified geometry into the
 * custom focusRect, with custom azimuth and tilt camera parameters. If
 * focusRect, azimuth or tilt is not provided, current map values is
 * used.
 *
 * Remark:
 * @param azimuth has optional type, it may be uninitialized.
 * @param tilt has optional type, it may be uninitialized.
 * @param focusRect has optional type, it may be uninitialized.
 */
- (nonnull YMKCameraPosition *)cameraPositionWithGeometry:(nonnull YMKGeometry *)geometry
                                                  azimuth:(nullable NSNumber *)azimuth
                                                     tilt:(nullable NSNumber *)tilt
                                                focusRect:(nullable YMKScreenRect *)focusRect;
/**
 * @return The map region that is currently visible. Region IS bounded
 * by latitude limits [-90, 90] and IS NOT bounded by longitude limits
 * [-180, 180]. If the longitude exceeds its limits, we see the world's
 * edge and another instance of the world beyond this edge.
 */
@property (nonatomic, readonly, nonnull) YMKVisibleRegion *visibleRegion;

/**
 * @return The map region that is visible from the given camera
 * position. Region IS bounded by latitude limits [-90, 90] and IS NOT
 * bounded by longitude limits [-180, 180]. If the longitude exceeds its
 * limits, we see the world's edge and another instance of the world
 * beyond this edge.
 */
- (nonnull YMKVisibleRegion *)visibleRegionWithCameraPosition:(nonnull YMKCameraPosition *)cameraPosition;

/**
 * Changes camera position. Can cancel a previous unfinished movement.
 *
 * @param animationType Required. Defines animation parameters. Deferred
 * teleportation can be achieved via Animation::Step with the necessary
 * duration. @see Animation for more details.
 * @param cameraCallback A function that takes the bool argument marking
 * the camera action complete. Invoked when: 1) A camera action is
 * cancelled (for example, as a result of a subsequent request for
 * camera movement), passing false as an argument. 2) A camera action
 * finished successfully, passing true as an argument.
 *
 * Remark:
 * @param cameraCallback has optional type, it may be uninitialized.
 */
- (void)moveWithCameraPosition:(nonnull YMKCameraPosition *)cameraPosition
                 animationType:(nonnull YMKAnimation *)animationType
                cameraCallback:(nullable YMKMapCameraCallback)cameraCallback;

/**
 * Immediately changes the camera position. Can cancel a previous
 * unfinished movement.
 */
- (void)moveWithCameraPosition:(nonnull YMKCameraPosition *)cameraPosition;

/**
 * Sets piecewise linear tilt depending on the zoom. 'points' must be
 * sorted by x; x coordinates must be unique. If zoom < minZoom(points)
 * or zoom > maxZoom(points), it is set within the defined bounds before
 * applying the function. If points is null or points.empty() it erases
 * the previously set function. If points.size() == 1, tilt is constant
 * and equals point.y.
 */
- (void)setTiltFunctionWithPoints:(nonnull NSArray<NSValue *> *)points;

/**
 * Minimum available zoom level.
 */
- (float)getMinZoom;

/**
 * Maximum available zoom level.
 */
- (float)getMaxZoom;

/**
 * Adds a layer that displays tiles from the user-defined TileProvider.
 * Sublayers will be added after corresponding sublayers of the map
 * layer.
 */
- (nonnull YMKLayer *)addLayerWithLayerId:(nonnull NSString *)layerId
                              contentType:(nonnull NSString *)contentType
                             layerOptions:(nonnull YMKLayerOptions *)layerOptions
                             tileProvider:(nonnull id<YMKTileProvider>)tileProvider
                         imageUrlProvider:(nonnull id<YMKImagesImageUrlProvider>)imageUrlProvider
                               projection:(nonnull YMKProjection *)projection;

/**
 * Adds a GeoJSON layer that displays tiles from the user-defined
 * TileProvider. Sublayers will be added after corresponding sublayers
 * of the map layer.
 */
- (nonnull YMKLayer *)addGeoJSONLayerWithLayerId:(nonnull NSString *)layerId
                                           style:(nonnull NSString *)style
                                    layerOptions:(nonnull YMKLayerOptions *)layerOptions
                                    tileProvider:(nonnull id<YMKTileProvider>)tileProvider
                                imageUrlProvider:(nonnull id<YMKImagesImageUrlProvider>)imageUrlProvider
                                      projection:(nonnull YMKProjection *)projection
                                      zoomRanges:(nonnull NSArray<YMKZoomRange *> *)zoomRanges;

/**
 * Adds a GeoJSON layer that uses the network to load tiles from URLs
 * obtained through UrlProvider. Sublayers will be added after
 * corresponding sublayers of the map layer.
 */
- (nonnull YMKLayer *)addGeoJSONLayerWithLayerId:(nonnull NSString *)layerId
                                           style:(nonnull NSString *)style
                                    layerOptions:(nonnull YMKLayerOptions *)layerOptions
                                 tileUrlProvider:(nonnull id<YMKTilesUrlProvider>)tileUrlProvider
                                imageUrlProvider:(nonnull id<YMKImagesImageUrlProvider>)imageUrlProvider
                                      projection:(nonnull YMKProjection *)projection
                                      zoomRanges:(nonnull NSArray<YMKZoomRange *> *)zoomRanges;

/**
 * Adds a layer that uses the network to load tiles from URLs obtained
 * through UrlProvider. Sublayers will be added after corresponding
 * sublayers of the map layer.
 *
 * @param layerId The id of the layer.
 * @param contentType Layer content type.
 * @param layerOptions Layer options.
 * @param tileUrlProvider Tile URL provider.
 * @param imageUrlProvider Image URL provider.
 * @param projection Projection.
 */
- (nonnull YMKLayer *)addLayerWithLayerId:(nonnull NSString *)layerId
                              contentType:(nonnull NSString *)contentType
                             layerOptions:(nonnull YMKLayerOptions *)layerOptions
                          tileUrlProvider:(nonnull id<YMKTilesUrlProvider>)tileUrlProvider
                         imageUrlProvider:(nonnull id<YMKImagesImageUrlProvider>)imageUrlProvider
                               projection:(nonnull YMKProjection *)projection;
/**
 * If enabled, night mode will reduce map brightness and improve
 * contrast.
 */
@property (nonatomic, getter=isNightModeEnabled) BOOL nightModeEnabled;
/**
 * Enable/disable zoom gestures, for example: - pinch - double tap (zoom
 * in) - tap with two fingers (zoom out)
 */
@property (nonatomic, getter=isZoomGesturesEnabled) BOOL zoomGesturesEnabled;
/**
 * Enable/disable scroll gestures, such as the pan gesture.
 */
@property (nonatomic, getter=isScrollGesturesEnabled) BOOL scrollGesturesEnabled;
/**
 * Enable/disable tilt gestures, such as parallel pan with two fingers.
 */
@property (nonatomic, getter=isTiltGesturesEnabled) BOOL tiltGesturesEnabled;
/**
 * Enable/disable rotation gestures, such as rotation with two fingers.
 */
@property (nonatomic, getter=isRotateGesturesEnabled) BOOL rotateGesturesEnabled;
/**
 * Removes the 300 ms delay in emitting a tap gesture. However, a
 * double-tap will emit a tap gesture along with a double-tap.
 */
@property (nonatomic, getter=isFastTapEnabled) BOOL fastTapEnabled;
/**
 * Sets the base map type.
 */
@property (nonatomic) YMKMapType mapType;

/**
 * Adds input listeners.
 */
- (void)addInputListenerWithInputListener:(nonnull id<YMKMapInputListener>)inputListener;

/**
 * Removes input listeners.
 */
- (void)removeInputListenerWithInputListener:(nonnull id<YMKMapInputListener>)inputListener;

/**
 * Adds camera listeners.
 */
- (void)addCameraListenerWithCameraListener:(nonnull id<YMKMapCameraListener>)cameraListener;

/**
 * Removes camera listeners.
 */
- (void)removeCameraListenerWithCameraListener:(nonnull id<YMKMapCameraListener>)cameraListener;

/**
 * Adds inertia move listeners.
 */
- (void)addInertiaMoveListenerWithInertiaMoveListener:(nonnull id<YMKInertiaMoveListener>)inertiaMoveListener;

/**
 * Removes inertia move listeners.
 */
- (void)removeInertiaMoveListenerWithInertiaMoveListener:(nonnull id<YMKInertiaMoveListener>)inertiaMoveListener;

/**
 * Sets a map loaded listener.
 *
 * Remark:
 * @param mapLoadedListener has optional type, it may be uninitialized.
 */
- (void)setMapLoadedListenerWithMapLoadedListener:(nullable id<YMKMapLoadedListener>)mapLoadedListener;
/**
 * @return List of map objects associated with the map. The layerId for
 * this collection can be retrieved via LayerIds.mapObjectsLayerId
 */
@property (nonatomic, readonly, readonly, nonnull) YMKMapObjectCollection *mapObjects;

/**
 * Adds a tap listener that is used to obtain brief geo object info.
 */
- (void)addTapListenerWithTapListener:(nonnull id<YMKLayersGeoObjectTapListener>)tapListener;

/**
 * Removes a tap listener that is used to obtain brief geo object info.
 */
- (void)removeTapListenerWithTapListener:(nonnull id<YMKLayersGeoObjectTapListener>)tapListener;

/**
 * Resets the currently selected geo object.
 */
- (void)deselectGeoObject;

/**
 * Selects a geo object with the specified objectId in the specified
 * layerId. If the object is not currently on the screen, it is selected
 * anyway, but the user will not actually see that. You need to move the
 * camera in addition to this call to be sure that the selected object
 * is visible for the user. Both objectId and layerId can be extracted
 * from the geo object's metadata container by using
 * geo_object_selection_metadata when the user taps on a geo object.
 */
- (void)selectGeoObjectWithObjectId:(nonnull NSString *)objectId
                            layerId:(nonnull NSString *)layerId;
/**
 * Yandex logo object.
 */
@property (nonatomic, readonly, readonly, nonnull) YMKLogo *logo;
/**
 * Enables/disables detailed 3D models on the map. Enabled by default.
 */
@property (nonatomic, getter=isModelsEnabled) BOOL modelsEnabled;
/**
 * Limits the number of visible basemap POIs.
 *
 * Optional property, can be nil.
 */
@property (nonatomic, nullable) NSNumber *poiLimit;

/**
 * Applies JSON style transformations to the map. Same as setMapStyle(0,
 * style). Affects VectorMap and Hybrid map types. Set to empty string
 * to clear previous styling. Returns true if the style was successfully
 * parsed, and false otherwise. If the returned value is false, the
 * current map style remains unchanged.
 */
- (BOOL)setMapStyleWithStyle:(nonnull NSString *)style;

/**
 * Applies JSON style transformations to the map. Replaces previous
 * styling with the specified ID (if such exists). Stylings are applied
 * in an ascending order. Affects VectorMap and Hybrid map types. Set to
 * empty string to clear previous styling with the specified ID. Returns
 * true if the style was successfully parsed, and false otherwise. If
 * the returned value is false, the current map style remains unchanged.
 */
- (BOOL)setMapStyleWithId:(NSInteger)id
                    style:(nonnull NSString *)style;

/**
 * Resets all JSON style transformations applied to the map.
 */
- (void)resetMapStyles;
/**
 * The icon set provides an interface for adding custom icons to be used
 * in layer customization. Affects VectorMap and Hybrid map types.
 */
@property (nonatomic, readonly, readonly, nonnull) YMKIconSet *layerIconSet;

/**
 * Forces the map to be flat. true - All loaded tiles start showing the
 * "flatten out" animation; all new tiles do not start 3D animation.
 * false - All tiles start showing the "rise up" animation.
 */
- (void)set2DModeWithEnable:(BOOL)enable;

/**
 * Set scale for 3D Objects height. boxesHeightScale - for scaling
 * buildings rendered as extruded polygons. modelsHeightScale - for
 * scaling buildings rendered as 3D models.
 */
- (void)setBuildingsHeightScaleWithBoxesHeightScale:(float)boxesHeightScale
                                  modelsHeightScale:(float)modelsHeightScale;

/**
 * Creates a new independent map object collection linked to the
 * specified layer ID. Sublayers will be added after corresponding
 * sublayers of the topmost layer.
 */
- (nonnull YMKMapObjectCollection *)addMapObjectLayerWithLayerId:(nonnull NSString *)layerId;
/**
 * Manages the collection of sublayers that define the drawing order.
 */
@property (nonatomic, readonly, readonly, nonnull) YMKSublayerManager *sublayerManager;

/**
 * Provides map projection
 */
- (nonnull YMKProjection *)projection;
/**
 * Selects one of predefined map style modes optimized for particular
 * use case(transit, driving, etc). Resets json styles set with
 * setMapStyle.
 */
@property (nonatomic) YMKMapMode mode;

/**
 * Returns the list of all objects from the specified layer currently
 * visible in the specified screen-space rectangle. Each returned geo
 * object will contain GeoObjectInspectionMetadata in its metadata
 * container.
 *
 * @param rect The screen-space rectangle containing the objects of
 * interest. If rect is null, all objects visible on the screen will be
 * returned.
 * @param layerId The id of a layer containing objects of interest. If
 * layerId is null, objects from all layers will be returned. Note: the
 * layerId for the built-in map object collection can be retrieved using
 * LayerIds.mapObjectsLayerId.
 *
 * Remark:
 * @param rect has optional type, it may be uninitialized.
 * @param layerId has optional type, it may be uninitialized.
 */
- (nonnull NSArray<YMKGeoObject *> *)visibleObjectsWithRect:(nullable YMKScreenRect *)rect
                                                    layerId:(nullable NSString *)layerId;

/**
 * Erases tiles, caches, etc. Does not trigger the next frame
 * generation.
 */
- (void)wipe;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
