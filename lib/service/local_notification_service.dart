import 'package:awaku/widgets/dynamic_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class LocalNotificationService {
// Instance of Flutternotification plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // Initialization setting for android
    InitializationSettings initializationSettingsAndroid =
        InitializationSettings(
            iOS: initializationSettingsDarwin,
            android:
                const AndroidInitializationSettings("@drawable/ic_launcher"));
    _notificationsPlugin.initialize(
      initializationSettingsAndroid,
      // to handle event when we receive notification
      onDidReceiveNotificationResponse: (details) {
        if (details.input != null) {}
      },
    );
  }

  static Future<void> display(RemoteMessage message) async {
    // To display the notification in device
    try {
      Logger().d(message.notification!.android!.sound);
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            message.notification!.android!.sound ?? "Channel Id",
            message.notification!.android!.sound ?? "Main Channel",
            groupKey: "gfg",
            color: Colors.green,
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound(
                message.notification!.android!.sound ?? "gfg"),

            // different sound for
            // different notification
            playSound: true,
            priority: Priority.high),
      );
      await _notificationsPlugin.show(id, message.notification?.title,
          message.notification?.body, notificationDetails,
          payload: message.data['route']);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void messageListener(BuildContext context) {
    // Either you can pass buildcontext or you
    // can take a context from navigator key
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger().d('Got a message in the foreground!');
      Logger().d('Message data: ${message.data}');

      if (message.notification != null) {
        Logger().d(
            'Message also contained a notification: so it will pop up ${message.notification?.body}');
        // Use a callback to avoid BuildContext usage across async gaps
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            showDialog(
                context: context,
                builder: ((BuildContext dialogContext) {
                  return DynamicDialog(
                      title: message.notification?.title,
                      body: message.notification?.body);
                }));
          }
        });
      }
    });
  }
}
