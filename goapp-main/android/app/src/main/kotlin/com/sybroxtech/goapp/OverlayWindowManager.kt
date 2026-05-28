package com.sybroxtech.goapp

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import kotlin.math.abs

object OverlayWindowManager {
    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private var lastX = 0
    private var lastY = 0
    private var touchX = 0f
    private var touchY = 0f

    fun hasPermission(context: Context): Boolean {
        return Settings.canDrawOverlays(context)
    }

    fun requestPermission(context: Context) {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}")
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun isActive(): Boolean {
        return overlayView != null
    }

    fun show(context: Context) {
        if (overlayView != null) return
        if (!hasPermission(context)) return
        val appContext = context.applicationContext
        val wm = appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager = wm

        val sizePx = (appContext.resources.displayMetrics.density * 64).toInt()
        val params = WindowManager.LayoutParams(
            sizePx,
            sizePx,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 0
        params.y = (appContext.resources.displayMetrics.density * 120).toInt()

        val bubble = FrameLayout(appContext)
        val bg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(0xFF1E1E1E.toInt())
        }
        bubble.background = bg

        val icon = ImageView(appContext).apply {
            setImageResource(R.mipmap.ic_launcher)
            scaleType = ImageView.ScaleType.CENTER_INSIDE
        }
        val iconSize = (sizePx * 0.6).toInt()
        val iconParams = FrameLayout.LayoutParams(iconSize, iconSize)
        iconParams.gravity = Gravity.CENTER
        bubble.addView(icon, iconParams)

        bubble.setOnTouchListener { v, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    touchX = event.rawX
                    touchY = event.rawY
                    lastX = params.x
                    lastY = params.y
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - touchX).toInt()
                    val dy = (event.rawY - touchY).toInt()
                    params.x = lastX + dx
                    params.y = lastY + dy
                    wm.updateViewLayout(v, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val dx = abs(event.rawX - touchX)
                    val dy = abs(event.rawY - touchY)
                    if (dx < 10 && dy < 10) {
                        bringToFront(appContext)
                    }
                    true
                }
                else -> false
            }
        }

        overlayView = bubble
        wm.addView(bubble, params)
    }

    fun hide() {
        val wm = windowManager ?: return
        overlayView?.let { view ->
            try {
                wm.removeView(view)
            } catch (_: Exception) {
            }
        }
        overlayView = null
    }

    private fun bringToFront(context: Context) {
        val intent = Intent(context, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            )
        }
        context.startActivity(intent)
    }
}

