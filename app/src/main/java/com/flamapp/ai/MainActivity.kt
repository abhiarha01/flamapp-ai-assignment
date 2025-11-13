package com.flamapp.ai

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.SurfaceHolder
import android.widget.ToggleButton
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.flamapp.ai.gl.GLFrameView

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
    }
}
