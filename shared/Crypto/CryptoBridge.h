#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CryptoBridge : NSObject

- (bool)generateKeyPair:(NSString *_Nullable*_Nonnull)privateKey publicKey:(NSString *_Nullable*_Nonnull)publicKey;
- (NSData * _Nullable)sign:(NSData *)data withPrivateKey:(NSData *)privateKey;

@end

NS_ASSUME_NONNULL_END
