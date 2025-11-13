package com.flamapp.ai.nativebridge

object NativeProcessor {
    init { System.loadLibrary("native-processor") }
    external fun processRgba(inputRgba: ByteArray, width: Int, height: Int, savePath: String? = null): ByteArray
}
