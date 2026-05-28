package com.sybroxtech.goapp

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import org.json.JSONObject

class BookingForegroundService : Service() {

    companion object {
        private const val CHANNEL_ID = "booking_flow"
        private const val NOTIFICATION_ID = 1401
        private const val ACTION_START = "booking.START"
        private const val ACTION_STOP = "booking.STOP"
        @Volatile
        var isRunning: Boolean = false

        fun start(context: Context) {
            val intent = Intent(context, BookingForegroundService::class.java).apply {
                action = ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, BookingForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var ticker: Runnable? = null
    private var running = false
    private var currentState = "SEARCHING_FOR_DRIVER"
    private var stageSeconds = 0
    private var etaMin = 8
    private var distanceKm = 3.0
    private var lastForeground: Boolean? = null
    private var lastSavedState: String? = null
    private var lastSavedEta: Int? = null
    private var lastSavedDistance: Double? = null
    private var lastSavedAtMs: Long = 0
    private var cachedSessionKey: String? = null
    private var cachedService: String? = null
    private val notificationHelper by lazy {
        BookingNotificationHelper(
            context = this,
            channelId = CHANNEL_ID,
            notificationId = NOTIFICATION_ID
        )
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopTicker()
                OverlayWindowManager.hide()
                clearProgress()
                stopForeground(true)
                stopSelf()
                running = false
                isRunning = false
                return START_NOT_STICKY
            }
            else -> {
                if (!running) {
                    running = true
                    isRunning = true
                    notificationHelper.ensureChannel()
                    startForeground(
                        NOTIFICATION_ID,
                        notificationHelper.buildNotification(currentState, etaMin)
                    )
                    restoreProgressIfAny()
                    syncOverlayWithForeground()
                    startTicker()
                }
            }
        }
        return START_STICKY
    }

    private fun startTicker() {
        ticker?.let { handler.removeCallbacks(it) }
        val task = object : Runnable {
            override fun run() {
                advanceState()
                updatePrefs()
                notificationHelper.update(currentState, etaMin, distanceKm)
                syncOverlayWithForeground()
                if (ticker !== this) return
                handler.postDelayed(this, 1000)
            }
        }
        ticker = task
        handler.postDelayed(task, 1000)
    }

    private fun stopTicker() {
        ticker?.let { handler.removeCallbacks(it) }
        ticker = null
    }

    private fun advanceState() {
        stageSeconds += 1
        when (currentState) {
            "SEARCHING_FOR_DRIVER" -> {
                if (stageSeconds >= 10) {
                    currentState = "DRIVER_ACCEPTED"
                    stageSeconds = 0
                    ensureDriverInfo()
                }
            }
            "DRIVER_ACCEPTED" -> {
                if (stageSeconds >= 5) {
                    currentState = "DRIVER_ARRIVING"
                    stageSeconds = 0
                }
            }
            "DRIVER_ARRIVING" -> {
                if (stageSeconds >= 20) {
                    currentState = "DRIVER_ARRIVED"
                    stageSeconds = 0
                } else {
                    etaMin = maxOf(1, etaMin - 1)
                    distanceKm = maxOf(0.1, distanceKm - 0.2)
                }
            }
            "DRIVER_ARRIVED" -> {
                if (stageSeconds >= 5) {
                    currentState = "RIDE_STARTED"
                    stageSeconds = 0
                }
            }
            "RIDE_STARTED" -> {
                if (stageSeconds >= 30) {
                    currentState = "REACHED_DROP_LOCATION"
                    stageSeconds = 0
                } else {
                    etaMin = maxOf(1, etaMin - 1)
                    distanceKm = maxOf(0.1, distanceKm - 0.2)
                }
            }
            "REACHED_DROP_LOCATION" -> {
                if (stageSeconds >= 5) {
                    currentState = "RIDE_COMPLETED"
                    stageSeconds = 0
                }
            }
            "RIDE_COMPLETED", "CANCELLED" -> {
                stopTicker()
                OverlayWindowManager.hide()
                clearProgress()
                stopForeground(true)
                stopSelf()
                running = false
                isRunning = false
            }
        }
    }

    private fun updatePrefs() {
        if (isAppForeground()) {
            return
        }
        val now = System.currentTimeMillis()
        val shouldSave = currentState != lastSavedState ||
            etaMin != lastSavedEta ||
            distanceKm != lastSavedDistance ||
            now - lastSavedAtMs >= 5000
        if (!shouldSave) return
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val editor = prefs.edit()
            .putString("flutter.booking_progress_state", currentState)
            .putInt("flutter.booking_progress_eta_min", etaMin)
            .putString("flutter.booking_progress_distance_km", distanceKm.toString())
        if (!cachedSessionKey.isNullOrBlank()) {
            editor.putString("flutter.booking_progress_session", cachedSessionKey)
        } else {
            editor.remove("flutter.booking_progress_session")
        }
        if (!cachedService.isNullOrBlank()) {
            editor.putString("flutter.booking_progress_service", cachedService)
        } else {
            editor.remove("flutter.booking_progress_service")
        }
        editor
            .apply()
        lastSavedState = currentState
        lastSavedEta = etaMin
        lastSavedDistance = distanceKm
        lastSavedAtMs = now
    }

    private fun clearProgress() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .remove("flutter.booking_progress_state")
            .remove("flutter.booking_progress_eta_min")
            .remove("flutter.booking_progress_distance_km")
            .remove("flutter.booking_session")
            .remove("flutter.booking_progress_driver_name")
            .remove("flutter.booking_progress_driver_vehicle")
            .remove("flutter.booking_progress_driver_plate")
            .remove("flutter.booking_progress_driver_phone")
            .remove("flutter.booking_progress_driver_otp")
            .remove("flutter.booking_progress_session")
            .remove("flutter.booking_progress_service")
            .apply()
    }

    private fun restoreProgressIfAny() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val stored = prefs.getString("flutter.booking_progress_state", null)
        if (stored != null) {
            currentState = stored
        }
        etaMin = safeGetInt(prefs, "flutter.booking_progress_eta_min", etaMin)
        val distanceRaw = prefs.getString("flutter.booking_progress_distance_km", null)
        distanceKm = distanceRaw?.toDoubleOrNull() ?: distanceKm
        cachedSessionKey = prefs.getString("flutter.booking_progress_session", null)
        cachedService = prefs.getString("flutter.booking_progress_service", null)
        if (cachedSessionKey == null || cachedService == null) {
            deriveSessionAndServiceFromBooking()
        }
    }

    private fun isAppForeground(): Boolean {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return prefs.getBoolean("flutter.booking_app_foreground", false)
    }

    private fun syncOverlayWithForeground() {
        val foreground = isAppForeground()
        if (lastForeground == null || foreground != lastForeground) {
            if (foreground) {
                OverlayWindowManager.hide()
            } else {
                OverlayWindowManager.show(this)
            }
            lastForeground = foreground
        }
    }

    private fun ensureDriverInfo() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        if (prefs.contains("flutter.booking_progress_driver_name")) return
        prefs.edit()
            .putString("flutter.booking_progress_driver_name", "Kumar")
            .putString("flutter.booking_progress_driver_vehicle", "Bike")
            .putString("flutter.booking_progress_driver_plate", "TN 01 ZZ 0001")
            .putString("flutter.booking_progress_driver_phone", "+91 90000 0001")
            .putString("flutter.booking_progress_driver_otp", "1234")
            .apply()
    }

    private fun safeGetInt(
        prefs: android.content.SharedPreferences,
        key: String,
        fallback: Int
    ): Int {
        val value = prefs.all[key] ?: return fallback
        return when (value) {
            is Int -> value
            is Long -> value.toInt()
            is String -> value.toIntOrNull() ?: fallback
            else -> fallback
        }
    }

    private fun deriveSessionAndServiceFromBooking() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("flutter.booking_session", null) ?: return
        try {
            val json = JSONObject(raw)
            val pickupLat = json.optDouble("pickupLat")
            val pickupLng = json.optDouble("pickupLng")
            val dropLat = json.optDouble("dropLat")
            val dropLng = json.optDouble("dropLng")
            val pickupLabel = json.optString("pickupLabel")
            val dropLabel = json.optString("dropLabel")
            cachedSessionKey =
                "$pickupLat,$pickupLng|$dropLat,$dropLng|$pickupLabel|$dropLabel"
            cachedService = json.optString("selectedService", cachedService ?: "")
        } catch (_: Exception) {
        }
    }
}
