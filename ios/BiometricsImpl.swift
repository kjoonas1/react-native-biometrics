import Foundation
import LocalAuthentication
import React

@objc
public class BiometricsImpl: NSObject {
  @objc public static let shared = BiometricsImpl()
  
  @objc
  public func isBiometricAvailable() -> NSNumber {
    let context = LAContext()
    var error: NSError?
    let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    return NSNumber(value: canEvaluate)
  }
  
  @objc
  public func authenticate(_ reason: String,
                           resolve: @escaping RCTPromiseResolveBlock,
                           reject: @escaping RCTPromiseRejectBlock) {
    let context = LAContext()
    var authError: NSError?
    
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
      resolve([
        "status": "DISABLED",
        "message": authError?.localizedDescription ?? "Biometrics not available"
      ])
      return
    }
    
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
      DispatchQueue.main.async {
        if success {
          resolve(["status": "SUCCESS"])
        } else {
          let status: String
          switch (error as? LAError)?.code {
          case .authenticationFailed:
            status = "FAILED_ATTEMPT"
          case .userCancel, .systemCancel:
            status = "CANCELLED"
          case .userFallback:
            status = "FALLBACK"
          case .biometryLockout:
            status = "LOCKOUT"
          case .biometryNotAvailable, .biometryNotEnrolled:
            status = "DISABLED"
          default:
            status = "ERROR"
          }
          
          resolve([
            "status": status,
            "message": error?.localizedDescription ?? "Authentication failed"
          ])
        }
      }
    }
  }
}
