import Foundation
import LocalAuthentication
import React
import Security

enum BiometricAuthStatus: String {
  case success = "SUCCESS"
  case failedAttempt = "FAILED_ATTEMPT"
  case cancelled = "CANCELLED"
  case fallback = "FALLBACK"
  case lockout = "LOCKOUT"
  case disabled = "DISABLED"
  case error = "ERROR"
}

enum BiometricAuthResult {
  case success
  case failure(BiometricAuthStatus, String)
}

@objc
public class BiometricsImpl: NSObject {
  @objc public static let shared = BiometricsImpl()
  @objc public static let crypto = CryptoBridge()
  
  @objc
  public func isFaceIDUsageDescriptionPresent() -> NSNumber {
    if let usageDescription = Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription") as? String {
      return NSNumber(value: !usageDescription.isEmpty)
    }
    return NSNumber(value: false)
  }
  
  @objc
  public func isBiometricAvailable() -> NSNumber {
    let context = LAContext()
    var error: NSError?
    let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    return NSNumber(value: canEvaluate)
  }
  
  @objc
  public func getPublicKey() -> NSString? {
    guard let publicKeyData = loadPublicKeyFromKeychain() else { return nil }
    return NSString(data: publicKeyData, encoding: String.Encoding.utf8.rawValue)
  }
  
  @objc
  public func generateKeyPair() -> NSString? {
    var publicKey: NSString?
    var privateKey: NSString?
    let result = BiometricsImpl.crypto.generateKeyPair(&privateKey, publicKey: &publicKey)
    guard result,
          let privKey = privateKey as String?,
          let pubKey = publicKey as String? else {
      return nil
    }
    
    let privSuccess = saveToKeychain("biometricPrivateKey", privKey)
    let pubSuccess = saveToKeychain("biometricPublicKey", pubKey)
    guard privSuccess && pubSuccess else {
      print("Failed to save keys to Keychain. Rolling back…")
      deleteFromKeychain("biometricPrivateKey")
      deleteFromKeychain("biometricPublicKey")
      return nil
    }
    return NSString(string: pubKey)
    
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
    
    Task {
      let result = await evaluatePolicy(context: context, reason: reason)
      switch result {
      case .success:
        resolve(["status": BiometricAuthStatus.success.rawValue])
      case .failure(let status, let message):
        resolve([
          "status": status.rawValue,
          "message": message,
        ])
      }
    }
  }
  
  @objc
  public func authenticateWithChallenge(_ reason: String,
                                        challenge: String,
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
    
    Task {
      let result = await evaluatePolicy(context: context, reason: reason)
      switch result {
      case .success:
        if let signature = signChallenge(challenge) {
          resolve([
            "status": BiometricAuthStatus.success.rawValue,
            "signature": signature
          ])
        } else {
          resolve([
            "status": BiometricAuthStatus.error.rawValue,
            "message": "Failed to sign challenge"
          ])
        }
      case .failure(let status, let message):
        resolve([
          "status": status.rawValue,
          "message": message,
        ])
      }
    }
  }
  
  private func signChallenge(_ challenge: String) -> String? {
    guard let privateKeyData = loadPrivateKeyFromKeychain() else {
      print("Failed to load private key from keychain")
      return nil
    }
    guard let challengeData = Data(base64Encoded: challenge) else {
      print("Failed to decode challenge from base64: \(challenge)")
      return nil
    }
    
    let signatureData = BiometricsImpl.crypto.sign(challengeData, withPrivateKey: privateKeyData)
    if let sig = signatureData {
      let base64Sig = sig.base64EncodedString()
      return base64Sig
    } else {
      print("Failed to generate signature")
      return nil
    }
  }
  
  
  private func evaluatePolicy(context: LAContext, reason: String) async -> BiometricAuthResult {
    await withCheckedContinuation { continuation in
      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
        DispatchQueue.main.async {
          if success {
            continuation.resume(returning: .success)
          } else {
            let status = BiometricsImpl.mapLAErrorToStatus(error: error)
            continuation.resume(returning: .failure(status, error?.localizedDescription ?? ""))
          }
        }
      }
    }
  }
  
  private func loadPublicKeyFromKeychain() -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: "biometricPublicKey",
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    
    guard status == errSecSuccess,
          let data = item as? Data else {
      print("Failed to load public key from Keychain: \(status)")
      return nil
    }
    
    return data
  }
  
  private func loadPrivateKeyFromKeychain() -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: "biometricPrivateKey",
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    
    guard status == errSecSuccess,
          let data = item as? Data else {
      print("Failed to load private key from Keychain: \(status)")
      return nil
    }
    
    return data
  }
  
  @discardableResult
  private func deleteFromKeychain(_ key: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key
    ]
    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess || status == errSecItemNotFound
  }
  
  private func saveToKeychain(_ key: String, _ value: String) -> Bool {
    let data = Data(value.utf8)
    
    guard let access = SecAccessControlCreateWithFlags(
      nil,
      kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      .biometryAny,
      nil
    ) else {
      return false
    }
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: data,
      kSecAttrAccessControl as String: access
    ]
    
    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
  }
  
  private static func mapLAErrorToStatus(error: Error?) -> BiometricAuthStatus {
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
