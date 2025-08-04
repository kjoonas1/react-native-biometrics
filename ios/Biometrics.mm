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
    
    NSError *authError = nil;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        resolve(@{ @"status": @"DISABLED", @"message": authError.localizedDescription ?: @"Biometrics not available" });
        return;
    }

    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
           localizedReason:reason
                     reply:^(BOOL success, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                resolve(@{ @"status": @"SUCCESS" });
            } else {
                NSString *status = @"ERROR";
                switch (error.code) {
                    case LAErrorAuthenticationFailed:
                        status = @"FAILED_ATTEMPT";
                        break;
                    case LAErrorUserCancel:
                        status = @"CANCELLED";
                        break;
                    case LAErrorUserFallback:
                        status = @"FALLBACK";
                        break;
                    case LAErrorSystemCancel:
                        status = @"CANCELLED";
                        break;
                    case LAErrorBiometryLockout:
                        status = @"LOCKOUT";
                        break;
                    case LAErrorBiometryNotAvailable:
                        status = @"DISABLED";
                        break;
                    case LAErrorBiometryNotEnrolled:
                        status = @"DISABLED";
                        break;
                    default:
                        status = @"ERROR";
                        break;
                }
                
                resolve(@{
                    @"status": status,
                    @"message": error.localizedDescription ?: @"Authentication failed"
                });
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
