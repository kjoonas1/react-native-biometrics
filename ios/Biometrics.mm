#import <LocalAuthentication/LocalAuthentication.h>
#import <React/RCTUtils.h>
#import "Biometrics.h"

@implementation Biometrics

RCT_EXPORT_MODULE()

- (NSNumber *)isBiometricAvailable {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    BOOL canEvaluate =
        [context canEvaluatePolicy:
                     LAPolicyDeviceOwnerAuthenticationWithBiometrics
                             error:&error];
    return @(canEvaluate);
}

- (void)authenticate:(NSString *)reason
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
    LAContext *context = [[LAContext alloc] init];
    [context
         evaluatePolicy:
             LAPolicyDeviceOwnerAuthenticationWithBiometrics
        localizedReason:reason
                  reply:^(BOOL success, NSError *_Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                      if (success) {
                          resolve(@(YES));
                      } else {
                          reject(@"AUTH_FAILED",
                                 error.localizedDescription
                                     ?: @"Authentication failed",
                                 error);
                      }
                    });
                  }];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeBiometricsSpecJSI>(
        params);
}

@end
