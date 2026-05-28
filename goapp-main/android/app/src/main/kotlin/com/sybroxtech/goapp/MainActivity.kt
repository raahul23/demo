package com.sybroxtech.goapp

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "booking_overlay"
    private val foregroundChannel = "booking_foreground"
    private val permissionChannel = "native_permissions"
    private val notificationChannel = "native_notifications"
    private var pendingResult: MethodChannel.Result? = null
    private var pendingPermission: String? = null
    private var pendingRequestCode: Int = 0

    companion object {
        private const val REQ_LOCATION = 1001
        private const val REQ_NOTIFICATION = 1002
    }

    override fun onResume() {
        super.onResume()
        setForegroundFlag(true)
    }

    override fun onPause() {
        setForegroundFlag(false)
        super.onPause()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "bringToFront" -> {
                    val intent = Intent(this, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "checkPermission" -> {
                    result.success(OverlayWindowManager.hasPermission(this))
                }
                "requestPermission" -> {
                    OverlayWindowManager.requestPermission(this)
                    result.success(true)
                }
                "showOverlay" -> {
                    OverlayWindowManager.show(this)
                    result.success(true)
                }
                "hideOverlay" -> {
                    OverlayWindowManager.hide()
                    result.success(true)
                }
                "isActive" -> {
                    result.success(OverlayWindowManager.isActive())
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, foregroundChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    BookingForegroundService.start(this)
                    result.success(true)
                }
                "stop" -> {
                    BookingForegroundService.stop(this)
                    result.success(true)
                }
                "isRunning" -> {
                    result.success(BookingForegroundService.isRunning)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, permissionChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestLocationWhenInUse" -> requestPermission(
                    result,
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    REQ_LOCATION,
                )
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(true)
                }
                "checkNotification" -> {
                    result.success(checkNotificationStatus())
                }
                "requestNotification" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                        result.success("granted")
                    } else {
                        requestPermission(
                            result,
                            Manifest.permission.POST_NOTIFICATIONS,
                            REQ_NOTIFICATION,
                        )
                    }
                }
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, notificationChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                    val channelId = args["channelId"] as? String ?: "ride_updates"
                    val channelName = args["channelName"] as? String ?: "Ride updates"
                    createNotificationChannel(channelId, channelName)
                    result.success(true)
                }
                "show" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                    showNotification(args)
                    result.success(true)
                }
                "cancel" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                    val id = (args["id"] as? Number)?.toInt() ?: 0
                    NotificationManagerCompat.from(this).cancel(id)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createNotificationChannel(channelId: String, channelName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            val existing = manager.getNotificationChannel(channelId)
            if (existing == null) {
                val channel = NotificationChannel(
                    channelId,
                    channelName,
                    NotificationManager.IMPORTANCE_HIGH
                )
                manager.createNotificationChannel(channel)
            }
        }
    }

    private fun showNotification(args: Map<*, *>) {
        val id = (args["id"] as? Number)?.toInt() ?: 0
        val title = args["title"] as? String ?: ""
        val body = args["body"] as? String ?: ""
        val progress = (args["progress"] as? Number)?.toInt()
        val ongoing = args["ongoing"] as? Boolean ?: false
        val channelId = args["channelId"] as? String ?: "ride_updates"
        val channelName = args["channelName"] as? String ?: "Ride updates"

        createNotificationChannel(channelId, channelName)

        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = if (intent != null) {
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            PendingIntent.getActivity(this, 0, intent, flags)
        } else {
            null
        }

        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(!ongoing)
            .setOngoing(ongoing)
            .setOnlyAlertOnce(progress != null)

        if (pendingIntent != null) {
            builder.setContentIntent(pendingIntent)
        }

        if (progress != null) {
            builder.setProgress(100, progress, false)
        } else {
            builder.setProgress(0, 0, false)
        }

        NotificationManagerCompat.from(this).notify(id, builder.build())
    }

    private fun requestPermission(
        result: MethodChannel.Result,
        permission: String,
        requestCode: Int,
    ) {
        if (pendingResult != null) {
            result.error("IN_PROGRESS", "Permission request already in progress", null)
            return
        }
        val granted = ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            result.success("granted")
            return
        }
        pendingResult = result
        pendingPermission = permission
        pendingRequestCode = requestCode
        ActivityCompat.requestPermissions(this, arrayOf(permission), requestCode)
    }

    private fun openAppSettings() {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.fromParts("package", packageName, null),
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun openNotificationSettings() {
        val intent = Intent()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            intent.action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
            intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            intent.action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
            intent.data = Uri.fromParts("package", packageName, null)
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun checkNotificationStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return "granted"
        }
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.POST_NOTIFICATIONS,
        ) == PackageManager.PERMISSION_GRANTED
        return if (granted) "granted" else "denied"
    }

    private fun setForegroundFlag(isForeground: Boolean) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        prefs.edit()
            .putBoolean("flutter.booking_app_foreground", isForeground)
            .apply()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (requestCode == pendingRequestCode && pendingResult != null) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            val permission = pendingPermission
            val status = if (granted) {
                "granted"
            } else if (permission != null &&
                !ActivityCompat.shouldShowRequestPermissionRationale(this, permission)
            ) {
                "permanentlyDenied"
            } else {
                "denied"
            }
            pendingResult?.success(status)
            pendingResult = null
            pendingPermission = null
            pendingRequestCode = 0
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
