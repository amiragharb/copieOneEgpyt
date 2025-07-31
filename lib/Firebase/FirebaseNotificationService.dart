import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'MessageStream.dart';

bool ONLUNCH = false;

/// Singleton Notification Service
class FirebaseNotificationService {
  // Singleton
  FirebaseNotificationService._internal() {
    // Setup listeners as soon as instance is created
    firebaseCloudMessagingListeners();
  }

  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  static FirebaseNotificationService get instance => _instance;

  final MessageStream _messageStream = MessageStream.instance;

  // (Optional) For backwards compatibility if you want direct access
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  /// Send Device Token to server or log it
  void sendDeviceToken() {
    FirebaseMessaging.instance.getToken().then((token) {
      print("MESSAGING TOKEN: $token");
      // Add your server-side send if required
    });
  }

  /// Set up listeners for notifications (foreground/background)
  Future<void> firebaseCloudMessagingListeners() async {
    if (Platform.isIOS) await getIOSPermission();

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage : ${message.data}");
      if (message.data.isNotEmpty) {
        ONLUNCH = false;
        _messageStream.addMessage(message);
      }
    });

    // When a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp : ${message.data}");
      if (message.data.isNotEmpty) {
        ONLUNCH = true;
        _messageStream.addMessage(message);
      }
    });

    // Optionally handle background & terminated states (see Firebase docs)
  }

  /// iOS Permission for notifications
  Future<void> getIOSPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // Optionally: Listen to permission changes
    // FirebaseMessaging.instance.onTokenRefresh.listen(...)
  }
}
