#import <LocalAuthentication/LocalAuthentication.h>
#import <React/RCTUtils.h>
#import "Biometrics.h"
#import "Biometrics-Swift.h"

@implementation Biometrics

RCT_EXPORT_MODULE()

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


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeBiometricsSpecJSI>(
        params);
}

@end
