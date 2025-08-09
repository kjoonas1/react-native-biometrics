package com.kallinen.biometrics

import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.biometrics.NativeBiometricsSpec
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys

class BiometricsModule(private val reactContext: ReactApplicationContext) :
  NativeBiometricsSpec(reactContext) {

  companion object {
      const val NAME = "Biometrics"

      init {
          System.loadLibrary("cryptohelper")
      }
  }

  override fun getPublicKey(): String? {
    return getSecuredKey("publicKey")
  }

  override fun deleteKeyPair(): Boolean {
    return true
  }

  override fun authenticateWithChallenge(reason: String, challenge: String, promise: Promise) {
    promise.resolve(createResultMap("SUCCESS"))
  }

  override fun isFaceIDUsageDescriptionPresent(): Boolean {
    return false
  }

  override fun generateKeyPair(): String? {
    val keys = generateKeyPairNative()
    if (keys == null || keys.size < 2) {
        return null
    }
    val privateKey = keys[0]
    val publicKey = keys[1]
    saveSecureKey("privateKey", privateKey)
    saveSecureKey("publicKey", publicKey)

    return publicKey
  }

  override fun isBiometricAvailable(): Boolean {
    val biometricManager = BiometricManager.from(reactContext)
    val canAuthenticate = biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)
    return canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
  }

  override fun authenticate(reason: String, promise: Promise) {
    val activity = currentActivity as? FragmentActivity
    if (activity == null) {
      promise.resolve(createResultMap("ERROR", "Current activity is null or not a FragmentActivity"))
      return
    }

    activity.runOnUiThread {
      val executor = ContextCompat.getMainExecutor(activity)

      var promiseHandled = false

      val callback = object : BiometricPrompt.AuthenticationCallback() {

        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
          if (promiseHandled) return
          promiseHandled = true
          promise.resolve(createResultMap("SUCCESS"))
        }

        override fun onAuthenticationError(code: Int, err: CharSequence) {
          if (promiseHandled) return
          promiseHandled = true

          val status = when (code) {
            BiometricPrompt.ERROR_NEGATIVE_BUTTON,
            BiometricPrompt.ERROR_USER_CANCELED -> "CANCELLED"

            BiometricPrompt.ERROR_LOCKOUT,
            BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> "LOCKOUT"

            BiometricPrompt.ERROR_NO_BIOMETRICS,
            BiometricPrompt.ERROR_HW_UNAVAILABLE,
            BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL -> "DISABLED"

            else -> "ERROR"
          }

          promise.resolve(createResultMap(status, err.toString()))
        }

        override fun onAuthenticationFailed() {
        }
      }

      val biometricPrompt = BiometricPrompt(activity, executor, callback)

      val promptInfo = BiometricPrompt.PromptInfo.Builder()
        .setTitle("Authentication Required")
        .setSubtitle(reason)
        .setNegativeButtonText("Cancel")
        .build()

      biometricPrompt.authenticate(promptInfo)
    }
  }

  private fun saveSecureKey(key: String, value: String) {
    val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
    val sharedPreferences = EncryptedSharedPreferences.create(
        "secure_prefs",
        masterKeyAlias,
        reactContext,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    sharedPreferences.edit().putString(key, value).apply()
}

  private fun getSecuredKey(key: String): String? {
    val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
    val sharedPreferences = EncryptedSharedPreferences.create(
        "secure_prefs",
        masterKeyAlias,
        reactContext,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    return sharedPreferences.getString(key, null)
  }

  private fun createResultMap(status: String, message: String? = null) =
    Arguments.createMap().apply {
      putString("status", status)
      message?.let { putString("message", it) }
    }

  override fun getName(): String = NAME

  private external fun generateKeyPairNative(): Array<String>?
}
