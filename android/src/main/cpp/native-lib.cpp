#include <jni.h>
#include <string>
#include <vector>
#include "CryptoHelper.h"
#include <android/log.h>
#define LOG_TAG "BiometricsModule"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static CryptoHelper cryptoHelper;

std::vector<uint8_t> toVector(JNIEnv* env, jbyteArray array) {
    jsize length = env->GetArrayLength(array);
    std::vector<uint8_t> vec(length);
    env->GetByteArrayRegion(array, 0, length, reinterpret_cast<jbyte*>(vec.data()));
    return vec;
}

jbyteArray toJByteArray(JNIEnv* env, const std::vector<uint8_t>& vec) {
    jbyteArray array = env->NewByteArray(vec.size());
    env->SetByteArrayRegion(array, 0, vec.size(), reinterpret_cast<const jbyte*>(vec.data()));
    return array;
}

extern "C"
JNIEXPORT jobjectArray JNICALL
Java_com_kallinen_biometrics_BiometricsModule_generateKeyPairNative(JNIEnv* env, jobject thiz) {
    std::string privateKey, publicKey;
    bool success = cryptoHelper.generateKeyPair(privateKey, publicKey);
    if (!success) return nullptr;

    jobjectArray result = env->NewObjectArray(2, env->FindClass("java/lang/String"), nullptr);
    if (result == nullptr) return nullptr;

    env->SetObjectArrayElement(result, 0, env->NewStringUTF(privateKey.c_str()));
    env->SetObjectArrayElement(result, 1, env->NewStringUTF(publicKey.c_str()));

    return result;
}

extern "C"
JNIEXPORT jbyteArray JNICALL
Java_com_kallinen_biometrics_BiometricsModule_signNative(JNIEnv* env, jobject thiz, jbyteArray data, jbyteArray privateKey) {
    std::vector<uint8_t> dataVec = toVector(env, data);
    std::vector<uint8_t> privKeyVec = toVector(env, privateKey);

    std::vector<uint8_t> signature = cryptoHelper.sign(dataVec, privKeyVec);
    if (signature.empty()) {
        return nullptr;
    }

    return toJByteArray(env, signature);
}
