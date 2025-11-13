package com.flamapp.ai

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Bundle
import android.os.Environment
import android.widget.ToggleButton
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.flamapp.ai.gl.GLFrameView
import com.flamapp.ai.nativebridge.NativeProcessor
import java.io.File
import java.nio.ByteBuffer

class MainActivity : ComponentActivity() {
    private lateinit var glView: GLFrameView
    private var showProcessed = true

    private val requestPermission = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) startCamera()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        glView = findViewById(R.id.gl_view)
        val toggle: ToggleButton = findViewById(R.id.toggle_button)
        toggle.setOnCheckedChangeListener { _, isChecked ->
            showProcessed = isChecked
            glView.setProcessedEnabled(showProcessed)
        }

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED
        ) {
            startCamera()
        } else {
            requestPermission.launch(Manifest.permission.CAMERA)
        }
    }

    private fun startCamera() {
        glView.startCamera(this)
        // Save one demo processed frame to app external files; use adb pull to web/assets later
        saveDemoProcessedFrame()
    }

    private fun saveDemoProcessedFrame() {
        val w = 640
        val h = 360
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        // Fill bitmap with a checkerboard
        val pixels = IntArray(w * h)
        for (y in 0 until h) {
            for (x in 0 until w) {
                val c = if (((x / 32) + (y / 32)) % 2 == 0) 0xFFFFAA00.toInt() else 0xFF0055FF.toInt()
                pixels[y * w + x] = c
            }
        }
        bmp.setPixels(pixels, 0, w, 0, 0, w, h)
        val buffer = ByteBuffer.allocate(w * h * 4)
        bmp.copyPixelsToBuffer(buffer)
        val rgba = buffer.array()

        val outFile = File(getExternalFilesDir(null), "processed_sample.png")
        val outBytes = NativeProcessor.processRgba(rgba, w, h, outFile.absolutePath)
        // We ignore outBytes here; GL renderer could use it to display processed frames
    }
}
