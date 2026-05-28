package com.sybroxtech.goapp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

class BookingNotificationHelper(
    private val context: Context,
    private val channelId: String,
    private val notificationId: Int,
) {
    private var lastNotifiedState: String? = null
    private var lastNotifiedEta: Int? = null
    private var lastNotifiedDistance: Double? = null
    private var lastNotifiedAtMs: Long = 0

    fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Booking flow",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    fun update(state: String, etaMin: Int, distanceKm: Double) {
        val now = System.currentTimeMillis()
        val shouldNotify = state != lastNotifiedState ||
            etaMin != lastNotifiedEta ||
            distanceKm != lastNotifiedDistance ||
            now - lastNotifiedAtMs >= 5000
        if (!shouldNotify) return
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(notificationId, buildNotification(state, etaMin))
        lastNotifiedState = state
        lastNotifiedEta = etaMin
        lastNotifiedDistance = distanceKm
        lastNotifiedAtMs = now
    }

    fun buildNotification(state: String, etaMin: Int): Notification {
        val text = when (state) {
            "SEARCHING_FOR_DRIVER" -> "Searching for driver"
            "DRIVER_ACCEPTED" -> "Driver accepted"
            "DRIVER_ARRIVING" -> "Driver arriving • ETA ${etaMin}m"
            "DRIVER_ARRIVED" -> "Driver arrived at pickup"
            "RIDE_STARTED" -> "On the way • ETA ${etaMin}m"
            "REACHED_DROP_LOCATION" -> "Reached drop location"
            "RIDE_COMPLETED" -> "Ride completed"
            else -> "Booking in progress"
        }
        return NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("GoApp")
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }
}
