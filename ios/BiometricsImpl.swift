import Foundation
import LocalAuthentication
import React

enum BiometricAuthStatus: String {
  case success = "SUCCESS"
  case failedAttempt = "FAILED_ATTEMPT"
  case cancelled = "CANCELLED"
  case fallback = "FALLBACK"
  case lockout = "LOCKOUT"
  case disabled = "DISABLED"
  case error = "ERROR"
}

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
    let available = isBiometricAvailable()
    
    guard available.boolValue else {
      resolve([
        "status": BiometricAuthStatus.disabled.rawValue,
        "message": "Biometrics not available"
      ])
      return
    }
    
    evaluatePolicy(context: context, reason: reason, resolve: resolve)
  }

  private func evaluatePolicy(context: LAContext,
                              reason: String,
                              resolve: @escaping RCTPromiseResolveBlock) {
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
      DispatchQueue.main.async {
        if success {
          resolve(["status": BiometricAuthStatus.success.rawValue])
        } else {
          let status = self.mapLAErrorToStatus(error: error)
          resolve([
            "status": status.rawValue,
            "message": error?.localizedDescription ?? "Authentication failed"
          ])
        }
      }
    }
  }
  
  private func mapLAErrorToStatus(error: Error?) -> BiometricAuthStatus {
    guard let laError = error as? LAError else { return .error }
    
    switch laError.code {
    case .authenticationFailed:
      return .failedAttempt
    case .userCancel, .systemCancel:
      return .cancelled
    case .userFallback:
      return .fallback
    case .biometryLockout:
      return .lockout
    case .biometryNotAvailable, .biometryNotEnrolled:
      return .disabled
    default:
      return .error
    }
  }
}
