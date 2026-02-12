#import <LocalAuthentication/LocalAuthentication.h>
#import <React/RCTUtils.h>
#import "Biometrics.h"
#import "CryptoBridge.h"
#import "Biometrics-Swift.h"

@implementation Biometrics

RCT_EXPORT_MODULE()

- (NSNumber *)isFaceIDUsageDescriptionPresent {
  BiometricsImpl *swiftInstance = [BiometricsImpl shared];
  return [swiftInstance isFaceIDUsageDescriptionPresent];
}

- (NSNumber *)isBiometricAvailable {
  BiometricsImpl *swiftInstance = [BiometricsImpl shared];
  return [swiftInstance isBiometricAvailable];
}

- (void)authenticate:(NSString *)reason
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  BiometricsImpl *swiftInstance = [BiometricsImpl shared];
  [swiftInstance authenticate:reason resolve:resolve reject:reject];
}

- (void)authenticateWithChallenge:(NSString *)reason challenge:(NSString *)challenge resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  BiometricsImpl *swiftInstance = [BiometricsImpl shared];
  [swiftInstance authenticateWithChallenge:reason challenge:challenge resolve:resolve reject:reject];
}

- (NSNumber *)deleteKeyPair {
  BiometricsImpl *swiftInstance = [BiometricsImpl shared];
  return [swiftInstance deleteKeyPair];
}

- (nullable NSString *)getPublicKey {
  BiometricsImpl *swiftInstance = [BiometricsImpl shared];
  return [swiftInstance getPublicKey];
}

- (nullable NSString *)generateKeyPair {
  BiometricsImpl *swiftInstance = [BiometricsImpl shared];
  return [swiftInstance generateKeyPair];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeBiometricsSpecJSI>(
        params);
}

@end
