package com.flamapp.ai.gl

import android.content.Context
import android.graphics.Bitmap
import android.graphics.SurfaceTexture
import android.hardware.camera2.*
import android.opengl.GLSurfaceView
import android.util.AttributeSet
import android.util.Size
import android.view.Surface
import androidx.core.content.getSystemService
import java.util.concurrent.ArrayBlockingQueue

class GLFrameView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : GLSurfaceView(context, attrs) {

    private val renderer = GLRenderer()
    private var processed = true

    private var cameraDevice: CameraDevice? = null
    private var session: CameraCaptureSession? = null

    init {
        setEGLContextClientVersion(2)
        setRenderer(renderer)
        renderMode = RENDERMODE_WHEN_DIRTY
    }

    fun setProcessedEnabled(enable: Boolean) {
        processed = enable
        renderer.setProcessedEnabled(enable)
    }

    fun startCamera(activity: Context) {
        val manager = activity.getSystemService<CameraManager>() ?: return
        val cameraId = manager.cameraIdList.firstOrNull() ?: return
        val characteristics = manager.getCameraCharacteristics(cameraId)
        val streamConfig = characteristics.get(
            CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP
        )
        val previewSize = streamConfig?.getOutputSizes(SurfaceTexture::class.java)?.firstOrNull() ?: Size(1280, 720)

        val texture = renderer.getOrCreateSurfaceTexture(previewSize.width, previewSize.height)
        val surface = Surface(texture)

        manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
            override fun onOpened(device: CameraDevice) {
                cameraDevice = device
                device.createCaptureSession(listOf(surface), object : CameraCaptureSession.StateCallback() {
                    override fun onConfigured(s: CameraCaptureSession) {
                        session = s
                        val request = device.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW).apply {
                            addTarget(surface)
                        }
                        s.setRepeatingRequest(request.build(), null, null)
                    }
                    override fun onConfigureFailed(s: CameraCaptureSession) {}
                }, null)
            }
            override fun onDisconnected(device: CameraDevice) { device.close() }
            override fun onError(device: CameraDevice, error: Int) { device.close() }
        }, null)

        renderer.setFrameListener { requestRender() }
    }
}
