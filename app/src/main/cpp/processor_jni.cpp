#include <jni.h>
#include <vector>
#include <string>
#include "processor.h"

using namespace flamapp;

extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_flamapp_ai_nativebridge_NativeProcessor_processRgba(
        JNIEnv* env, jobject /*thiz*/, jbyteArray inputRgba, jint width, jint height, jstring savePath) {
    const jsize len = env->GetArrayLength(inputRgba);
    std::vector<uint8_t> inbuf(len);
    env->GetByteArrayRegion(inputRgba, 0, len, reinterpret_cast<jbyte*>(inbuf.data()));

    auto out = process_rgba(inbuf.data(), width, height);

    if (savePath != nullptr) {
        const char* path = env->GetStringUTFChars(savePath, nullptr);
        save_png(out.data(), width, height, path);
        env->ReleaseStringUTFChars(savePath, path);
    }

    jbyteArray jOut = env->NewByteArray((jsize)out.size());
    env->SetByteArrayRegion(jOut, 0, (jsize)out.size(), reinterpret_cast<const jbyte*>(out.data()));
    return jOut;
}
