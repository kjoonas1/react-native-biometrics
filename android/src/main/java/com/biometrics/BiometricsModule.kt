package com.kallinen.biometrics

import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricPrompt.PromptInfo
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.biometrics.NativeBiometricsSpec
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext

class BiometricsModule(private val reactContext: ReactApplicationContext) : NativeBiometricsSpec(reactContext) {

  companion object {
    const val NAME = "Biometrics"
  }

  override fun isBiometricAvailable(): Boolean {
    val biometricManager = BiometricManager.from(reactContext)
    val canAuthenticate = biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)

    return canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
  }

  override fun authenticate(reason: String, promise: Promise) {
    val activity = currentActivity as? FragmentActivity
    if (activity == null) {
      promise.reject("NO_ACTIVITY", "Current activity is null or not a FragmentActivity")
      return
    }

    activity.runOnUiThread {
      val executor = ContextCompat.getMainExecutor(activity)

      val callback = object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
          promise.resolve(true)
        }

        override fun onAuthenticationError(code: Int, err: CharSequence) {
          promise.reject("AUTH_FAILED", err.toString())
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


  override fun getName(): String = NAME
}
