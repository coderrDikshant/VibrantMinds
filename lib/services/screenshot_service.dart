// lib/services/screenshot_service.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // Import for debugPrint

class ScreenshotService {
  static const MethodChannel _channel = MethodChannel('com.example.user_end/screenshot_protector');

  static int _screenshotAttempts = 0;
  static const int _maxScreenshotAttempts = 2; // Allows 2 warnings, 3rd attempt exits

  static Future<void> disableScreenshots() async {
    try {
      await _channel.invokeMethod('disableScreenshots');
      debugPrint('Screenshots disabled (Android).');
    } on PlatformException catch (e) {
      debugPrint("Failed to disable screenshots: '${e.message}'. This is expected on iOS.");
    }
  }

  static Future<void> enableScreenshots() async {
    try {
      await _channel.invokeMethod('enableScreenshots');
      debugPrint('Screenshots enabled (Android).');
    } on PlatformException catch (e) {
      debugPrint("Failed to enable screenshots: '${e.message}'. This is expected on iOS.");
    }
  }

  static void setupMethodCallHandler(Function(String message, bool shouldExit) onScreenshotDetected) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "screenshotTaken") {
        debugPrint('Screenshot taken notification received from native!');
        _screenshotAttempts++;

        String message;
        bool shouldExit = false;

        if (_screenshotAttempts == 1) {
          message = "Warning: Taking screenshots is prohibited. One more attempt will exit the quiz.";
        } else if (_screenshotAttempts == _maxScreenshotAttempts) {
          message = "Last warning: Taking screenshots is strictly prohibited. Next attempt will exit the quiz automatically.";
        } else if (_screenshotAttempts > _maxScreenshotAttempts) {
          message = "Multiple screenshot attempts detected! The quiz will exit automatically.";
          shouldExit = true; // This will be true on the 3rd attempt
        } else {
            // Fallback for unexpected scenarios, though with _maxScreenshotAttempts=2, this should be fine
            message = "Screenshot detected (unexpected attempt count).";
        }
        
        debugPrint('ScreenshotService: Attempts: $_screenshotAttempts, Should Exit: $shouldExit, Message: "$message"'); // ADDED DEBUG PRINT

        onScreenshotDetected(message, shouldExit);
      }
    });
  }

  static void resetScreenshotAttempts() {
    _screenshotAttempts = 0;
    debugPrint('Screenshot attempts reset.');
  }
}