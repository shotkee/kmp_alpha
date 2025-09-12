#import <YandexMapsMobile/YRTExport.h>

#import <Foundation/Foundation.h>

/**
 * :nodoc:
 */
YRT_EXPORT @interface YRTRsaPublicKey : NSObject

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSData *modulus;

/**
 * Undocumented
 */
@property (nonatomic, readonly, nonnull) NSData *publicExponent;


+ (nonnull YRTRsaPublicKey *)rsaPublicKeyWithModulus:(nonnull NSData *)modulus
                                      publicExponent:(nonnull NSData *)publicExponent;


@end
