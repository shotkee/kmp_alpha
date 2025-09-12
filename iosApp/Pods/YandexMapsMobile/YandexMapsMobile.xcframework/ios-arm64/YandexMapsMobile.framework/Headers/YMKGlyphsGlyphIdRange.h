#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * :nodoc:
 */
YRT_EXPORT @interface YMKGlyphsGlyphIdRange : NSObject

/**
 * Undocumented
 */
@property (nonatomic, readonly) NSUInteger firstGlyphId;

/**
 * Undocumented
 */
@property (nonatomic, readonly) NSUInteger lastGlyphId;


+ (nonnull YMKGlyphsGlyphIdRange *)glyphIdRangeWithFirstGlyphId:( NSUInteger)firstGlyphId
                                                    lastGlyphId:( NSUInteger)lastGlyphId;


@end
