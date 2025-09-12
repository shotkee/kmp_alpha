#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * The ID of a tile on the map.
 */
YRT_EXPORT @interface YMKTileId : NSObject

/**
 * The number of the tile horizontally.
 */
@property (nonatomic, readonly) NSUInteger x;

/**
 * The number of the tile vertically.
 */
@property (nonatomic, readonly) NSUInteger y;

/**
 * The number of columns and rows to split the map into.
 */
@property (nonatomic, readonly) NSUInteger z;


+ (nonnull YMKTileId *)tileIdWithX:( NSUInteger)x
                                 y:( NSUInteger)y
                                 z:( NSUInteger)z;


@end
