import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'amplifyconfiguration.dart';
import 'services/firestore_service.dart';
import 'theme/vibrant_theme.dart';
import 'splash_screen.dart';
import 'models/notification_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'default_channel',
  'Default Notifications',
  importance: Importance.high,
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(NotificationModelAdapter());
  }

  final box = await Hive.openBox<NotificationModel>('notificationsBox');

  final notification = message.notification;
  if (notification != null) {
    await box.add(NotificationModel(
      title: notification.title ?? 'No Title',
      body: notification.body ?? 'No Body',
      receivedAt: DateTime.now(),
    ));
    print("✅ Notification saved in Hive from terminated state.");
  }
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuthApp());
 _initializeServices();
}


Future<void> _initializeServices() async {
  await Hive.initFlutter();

  Hive.registerAdapter(NotificationModelAdapter());
  await Hive.openBox<NotificationModel>('notificationsBox');

  // other boxes
  await Hive.openBox('profileBox');
  await Hive.openBox('jobCacheBox');
  await Hive.openBox('fcmBox');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _configureAmplify();
  await _initNotifications();
}

Future<void> _configureAmplify() async {
  try {
    if (!Amplify.isConfigured) {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyconfig);
      safePrint('✅ Amplify configured successfully');
    } else {
      safePrint('⚠️ Amplify already configured');
    }
  } on AmplifyException catch (e) {
    safePrint('❌ Amplify configuration error: ${e.message}');
  } catch (e) {
    safePrint('❌ Unknown error during Amplify config: $e');
  }
}

Future<void> _initNotifications() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

await flutterLocalNotificationsPlugin.initialize(
  initSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) {
    final payload = response.payload;
    print("🔁 Notification tapped with payload: $payload");

    // You can handle navigation or custom logic here
  },
);


  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission();
  print('🔒 Notification permission: ${settings.authorizationStatus}');

 FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    // Save to Hive
    final box = Hive.box<NotificationModel>('notificationsBox');
    await box.add(NotificationModel(
      title: notification.title ?? 'No Title',
      body: notification.body ?? 'No Body',
      receivedAt: DateTime.now(),
    ));

    // Show local notification
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(notification.body ?? ''),
        ),
      ),
    );
  }
});


  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("📲 App opened via notification: ${message.data}");
    // Handle screen navigation here if needed
  });
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => FirestoreService(FirebaseFirestore.instance),
        ),
      ],
      child: Authenticator(child: const MyApp()),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vibrant Minds App',
      theme: VibrantTheme.themeData,
      builder: Authenticator.builder(),
      home: const SplashScreen(),
    );
  }
}
