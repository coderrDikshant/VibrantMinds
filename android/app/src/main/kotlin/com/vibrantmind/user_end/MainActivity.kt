package com.vibrantmind.myapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager 

class MainActivity: FlutterActivity() {
    // Define the channel name. This must match the name used in your ScreenshotService.dart.
    private val CHANNEL = "com.vibrantmind.myapp/screenshot_protector" // <--- IMPORTANT: Change 'com.your_app_name' to 'com.vibrantmind.myapp'

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Set up the MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "disableScreenshots" -> {
                    // Add FLAG_SECURE to the window to prevent screenshots and screen recording
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null) // Return success to Flutter
                }
                "enableScreenshots" -> {
                    // Clear FLAG_SECURE from the window to allow screenshots again
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null) // Return success to Flutter
                }
                else -> {
                    // If the method called from Flutter is not recognized, indicate it's not implemented
                    result.notImplemented()
                }
            }
        }
    }
}
