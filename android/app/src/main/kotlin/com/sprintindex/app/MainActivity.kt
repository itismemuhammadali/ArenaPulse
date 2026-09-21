package com.sprintindex.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sprintindex.app/maps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setMapsApiKey" -> {
                    val apiKey = call.argument<String>("apiKey")
                    if (apiKey != null && apiKey.isNotEmpty()) {
                        com.google.android.gms.maps.MapsInitializer.initialize(this, com.google.android.gms.maps.MapsInitializer.Renderer.LATEST) {
                            // Initialization complete
                        }
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "API key is null or empty", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            // Messages Channel
            val messagesChannel = NotificationChannel(
                "messages",
                "Messages",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Direct messages and club messages"
                enableVibration(true)
                enableLights(true)
                setShowBadge(true)
            }

            // Social Channel (follows, likes, comments)
            val socialChannel = NotificationChannel(
                "social",
                "Social Activity",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Likes, comments, and follows"
                enableVibration(true)
                enableLights(false)
                setShowBadge(true)
            }

            // Club Updates Channel
            val clubsChannel = NotificationChannel(
                "clubs",
                "Club Updates",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Club posts, join requests, and member updates"
                enableVibration(true)
                enableLights(false)
                setShowBadge(true)
            }

            // Posts Channel
            val postsChannel = NotificationChannel(
                "posts",
                "New Posts",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Posts from people you follow"
                enableVibration(false)
                enableLights(false)
                setShowBadge(true)
            }

            // System Channel (uploads, errors)
            val systemChannel = NotificationChannel(
                "system",
                "System Notifications",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Upload status and system messages"
                enableVibration(false)
                enableLights(false)
                setShowBadge(false)
            }

            notificationManager?.createNotificationChannel(messagesChannel)
            notificationManager?.createNotificationChannel(socialChannel)
            notificationManager?.createNotificationChannel(clubsChannel)
            notificationManager?.createNotificationChannel(postsChannel)
            notificationManager?.createNotificationChannel(systemChannel)
        }
    }
}
