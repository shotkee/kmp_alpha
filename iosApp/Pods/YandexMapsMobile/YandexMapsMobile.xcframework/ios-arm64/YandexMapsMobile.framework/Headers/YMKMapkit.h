#import <YandexMapsMobile/YMKDummyLocationManager.h>
#import <YandexMapsMobile/YMKGeometry.h>
#import <YandexMapsMobile/YMKLocationLocationManager.h>
#import <YandexMapsMobile/YMKLocationSimulator.h>
#import <YandexMapsMobile/YMKMapWindow.h>
#import <YandexMapsMobile/YMKOfflineCacheManager.h>
#import <YandexMapsMobile/YMKStorageStorageManager.h>
#import <YandexMapsMobile/YMKTrafficLayer.h>
#import <YandexMapsMobile/YMKUserLocation.h>
#import <YandexMapsMobile/YRTExport.h>
#import <YandexMapsMobile/YRTPlatformView_Fwd.h>
#import <YandexMapsMobile/YRTSensors.h>

/**
 * Provides access to all services in the SDK.
 *
 * Initialize the MapKit factory before using this class.
 *
 * Note: MapKit holds listener/delegate objects by weak references. You
 * need to have strong references to them somewhere in the client code.
 */
YRT_EXPORT @interface YMKMapKit : NSObject

/**
 * :nodoc:
 * Sets the key for API access.
 *
 * @param key Key issued in the Developer Dashboard.
 */
- (void)setApiKeyWithKey:(nonnull NSString *)key;

/**
 * Sets single global location manager that is used by every module in
 * MapKit by default. The provided location manager must have async
 * implementation in it. Any location manager created by MapKit has
 * async implementation. To provide your own source of location please
 * use DummyLocationManager. Application can change location manager at
 * any moment, all MapKit modules will start receiving new location
 * immediately.
 */
- (void)setLocationManagerWithLocationManager:(nonnull YMKLocationManager *)locationManager;

/**
 * Resets the global location manager to a default one, i.e. a location
 * manager that is created by MapKit.createLocationManager() call.
 */
- (void)resetLocationManagerToDefault;

/**
 * Notifies MapKit when the application resumes the foreground state.
 */
- (void)onStart;

/**
 * Notifies MapKit when the application pauses and goes to the
 * background.
 */
- (void)onStop;

/**
 * Creates a manager that allows to listen for device location updates.
 */
- (nonnull YMKLocationManager *)createLocationManager;

/**
 * Creates a manager that allows to listen for device location updates,
 * uses activityType as a hint.
 */
- (nonnull YMKLocationManager *)createLocationManagerWithActivityType:(YRTLocationActivityType)activityType;

/**
 * Creates a suspended LocationSimulator object with the given geometry.
 */
- (nonnull YMKLocationSimulator *)createLocationSimulatorWithGeometry:(nonnull YMKPolyline *)geometry;

/**
 * Creates a suspended LocationSimulator object. Geometry must be set
 * manually.
 */
- (nonnull YMKLocationSimulator *)createLocationSimulator;

/**
 * Creates a manager that functions as a location proxy.
 */
- (nonnull YMKDummyLocationManager *)createDummyLocationManager;

/**
 * :nodoc:
 * Creates an internal "window" object that is used to show the map.
 *
 * Do not call this method - it is for internal use only. To show the
 * map, please use the corresponding map "view" object.
 */
- (nonnull YMKMapWindow *)createMapWindowWithPlatformView:(nonnull id<YRTPlatformView>)platformView;

/**
 * Creates the traffic layer.
 */
- (nonnull YMKTrafficLayer *)createTrafficLayerWithMapWindow:(nonnull YMKMapWindow *)mapWindow;

/**
 * :nodoc:
 * Creates an internal "window" object that is used to show the map with
 * a custom scale factor. The scale factor is equal to the number of
 * pixels per device-independent point.
 *
 * Do not call this method - it is for internal use only. To show the
 * map, please use the corresponding map "view" object.
 */
- (nonnull YMKMapWindow *)createMapWindowWithPlatformView:(nonnull id<YRTPlatformView>)platformView
                                        customScaleFactor:(float)customScaleFactor;

/**
 * Undocumented
 */
- (nonnull YMKOffscreenMapWindow *)createOffscreenMapWindowWithWidth:(NSInteger)width
                                                              height:(NSInteger)height;

/**
 * Undocumented
 */
- (nonnull YMKOffscreenMapWindow *)createOffscreenMapWindowWithWidth:(NSInteger)width
                                                              height:(NSInteger)height
                                                   customScaleFactor:(float)customScaleFactor;
/**
 * @attention This feature is not available in the free MapKit version.
 *
 *
 * Returns a manager that handles offline maps, search index and road
 * graph.
 */
@property (nonatomic, readonly, readonly, nonnull) YMKOfflineCacheManager *offlineCacheManager;
/**
 * Returns a manager that handles disk size and IO errors.
 */
@property (nonatomic, readonly, readonly, nonnull) YMKStorageManager *storageManager;

/**
 * Create layer with the user location icon.
 */
- (nonnull YMKUserLocationLayer *)createUserLocationLayerWithMapWindow:(nonnull YMKMapWindow *)mapWindow;
/**
 * Returns the version of the MapKit bundle.
 */
@property (nonatomic, readonly, nonnull) NSString *version;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
