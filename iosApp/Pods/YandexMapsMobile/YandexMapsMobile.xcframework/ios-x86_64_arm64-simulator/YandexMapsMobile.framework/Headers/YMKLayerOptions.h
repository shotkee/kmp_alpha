#import <YandexMapsMobile/YMKOverzoomMode.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Options that are used when adding a layer to the map.
 */
YRT_EXPORT @interface YMKLayerOptions : NSObject

/**
 * Inactive layers are not displayed on the map and do not request any
 * tiles from TileProvider.
 */
@property (nonatomic, assign) BOOL active;

/**
 * Indicates the availability of night mode for this layer (for example,
 * night mode is disabled for the satellite layer). Default: true.
 */
@property (nonatomic, assign) BOOL nightModeAvailable;

/**
 * Determines whether tiles are cached on persistent storage or not.
 */
@property (nonatomic, assign) BOOL cacheable;

/**
 * Indicates whether layer activation/deactivation should be animated.
 */
@property (nonatomic, assign) BOOL animateOnActivation;

/**
 * Specifies duration of tile appearing animation. Can be set to 0 to
 * disable animation. Default: 400 ms
 */
@property (nonatomic, assign) NSTimeInterval tileAppearingAnimationDuration;

/**
 * Whether to render tiles from adjacent zoom levels in place of absent
 * or translucent tiles.
 */
@property (nonatomic, assign) YMKOverzoomMode overzoomMode;

/**
 * Set this flag if layer is transparent, i.e. parts of underlying
 * layers can be seen through it. This will disable some rendering
 * optimizations that take advantage of layer opacity.
 */
@property (nonatomic, assign) BOOL transparent;

+ (nonnull YMKLayerOptions *)layerOptionsWithActive:( BOOL)active
                                 nightModeAvailable:( BOOL)nightModeAvailable
                                          cacheable:( BOOL)cacheable
                                animateOnActivation:( BOOL)animateOnActivation
                     tileAppearingAnimationDuration:( NSTimeInterval)tileAppearingAnimationDuration
                                       overzoomMode:( YMKOverzoomMode)overzoomMode
                                        transparent:( BOOL)transparent;


- (nonnull YMKLayerOptions *)init;

@end
