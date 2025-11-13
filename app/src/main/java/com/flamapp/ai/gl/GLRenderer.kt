package com.flamapp.ai.gl

import android.graphics.SurfaceTexture
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class GLRenderer : GLSurfaceView.Renderer {
    private var surfaceTexture: SurfaceTexture? = null
    private var frameListener: (() -> Unit)? = null
    private var processed = true

    fun setProcessedEnabled(enable: Boolean) { processed = enable }
    fun setFrameListener(cb: () -> Unit) { frameListener = cb }

    fun getOrCreateSurfaceTexture(w: Int, h: Int): SurfaceTexture {
        if (surfaceTexture == null) {
            val texIds = IntArray(1)
            GLES20.glGenTextures(1, texIds, 0)
            val texId = texIds[0]
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texId)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            surfaceTexture = SurfaceTexture(texId)
            surfaceTexture!!.setOnFrameAvailableListener { frameListener?.invoke() }
        }
        return surfaceTexture!!
    }

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0f, 0f, 0f, 1f)
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, height)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        surfaceTexture?.updateTexImage()
        // For starter: clear only; shaders/resources added later
    }
}
