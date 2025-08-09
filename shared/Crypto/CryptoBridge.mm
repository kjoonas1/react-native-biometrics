#import "CryptoBridge.h"
#import "CryptoHelper.h"
#include <vector>

@implementation CryptoBridge {
    CryptoHelper *_helper;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _helper = new CryptoHelper();
    }
    return self;
}

- (void)dealloc {
    delete _helper;
}

- (NSData * _Nullable)sign:(NSData *)data withPrivateKey:(NSData *)privateKey {
    if (!data || !privateKey) return nil;

    const uint8_t *dataBytes = (const uint8_t *)data.bytes;
    const uint8_t *keyBytes = (const uint8_t *)privateKey.bytes;

    std::vector<uint8_t> inputVec(dataBytes, dataBytes + data.length);
    std::vector<uint8_t> keyVec(keyBytes, keyBytes + privateKey.length);

    std::vector<uint8_t> signatureVec = _helper->sign(inputVec, keyVec);
    if (signatureVec.empty()) {
        return nil;
    }

    return [NSData dataWithBytes:signatureVec.data() length:signatureVec.size()];
}


- (bool)generateKeyPair:(NSString **)privateKey publicKey:(NSString **)publicKey {
    std::string privateKeyStr;
    std::string publicKeyStr;

    bool result = _helper->generateKeyPair(privateKeyStr, publicKeyStr);

    if (result) {
        if (privateKey) {
            *privateKey = [NSString stringWithUTF8String:privateKeyStr.c_str()];
        }
        if (publicKey) {
            *publicKey = [NSString stringWithUTF8String:publicKeyStr.c_str()];
        }
    }
  
    return result;
}


@end
