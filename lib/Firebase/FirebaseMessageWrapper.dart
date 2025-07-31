import 'dart:io' show Platform;

import 'package:egpycopsversion4/Home/homeFragment.dart';
import 'package:egpycopsversion4/Home/youtubeLiveVideoDetailsActivityFromNotification.dart';
import 'package:egpycopsversion4/NewsFeed/NewsFeedDetailsActivityFromNotification.dart';
import 'package:egpycopsversion4/Notifications/notificationDetails.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'MessageStream.dart';

bool enterNotificationClick = false;
bool ONLUNCH = false;

/// Background notification tap handler (required to be a top-level or static function)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  // Keep minimal: you cannot use context here.
  // If needed, persist payload for later handling on app resume.
  // Example:
  // final payload = details.payload;
  // // Save payload to preferences for handling after app starts/resumes.
}

class FirebaseMessageWrapper extends StatefulWidget {
  final Widget child;

  const FirebaseMessageWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<FirebaseMessageWrapper> createState() => _FirebaseMessageWrapperState();
}


class _FirebaseMessageWrapperState extends State<FirebaseMessageWrapper> {
  final MessageStream _messageStream = MessageStream.instance;

  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late final AndroidInitializationSettings androidInitializationSettings;
  late final DarwinInitializationSettings iosInitializationSettings;
  late final InitializationSettings initializationSettings;

  // Optional: define your Android channel once
  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'default_notification_channel_id',
    'Channel title',
    description: 'Channel body',
    importance: Importance.high,
    playSound: true,
  );

  @override
  void initState() {
    super.initState();
    initializing();
  }

  Future<void> initializing() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // iOS init
    iosInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Show notification while app is in foreground (iOS 10+)
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    // Android init
    androidInitializationSettings = const AndroidInitializationSettings(
      'logotransparents', // must exist in mipmap/drawable without extension
    );

    initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Create Android channel (Android 8+)
    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(_defaultChannel);
      // Android 13+: request POST_NOTIFICATIONS permission
// après avoir créé le channel Android…
if (Platform.isAndroid) {
  await _ensureAndroidNotificationPermission();
}
    }

    // iOS: request permissions explicitly too (optional, already requested by DarwinInitializationSettings)
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Initialize plugin and handle taps
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        onSelectNotification(details.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // If app was launched via a notification, handle the initial payload
    final launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    final payloadAtLaunch = launchDetails?.notificationResponse?.payload;
    if (payloadAtLaunch != null && payloadAtLaunch.isNotEmpty) {
      // Delay to ensure navigator is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSelectNotification(payloadAtLaunch);
      });
    }
  }

  // ---------- NOTIFICATION HELPERS (instance methods) ----------

  Future<void> _showNotification(String title, String body, String itemID) async {
    await _notify(title, body, '$itemID,basic');
  }

  Future<void> _showNewsNotification(
      String title, String body, String itemID, String category) async {
    await _notify(title, body, '$itemID,$category');
  }

  Future<void> _showLiveNotification(
      String title, String body, String itemID, String category) async {
    await _notify(title, body, '$itemID,$category');
  }

  Future<void> _notify(String title, String body, String payload) async {
    const androidDetails = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDescription,
      priority: Priority.high,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('bellsound'),
      ticker: 'notification',
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'bellsound.caf',
    );

    final details = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // consider unique ids if you need stacking
      title,
      body,
      details,
      payload: payload,
    );
  }

  static const String _defaultChannelId = 'default_notification_channel_id';
  static const String _defaultChannelName = 'Channel title';
  static const String _defaultChannelDescription = 'Channel body';

  // ---------- TAP HANDLER ----------

  Future<void> onSelectNotification(String? payload) async {
    if (payload == null || payload.isEmpty) return;

    // prevent double openings
    if (!enterNotificationClick) enterNotificationClick = true;

    final split = payload.split(',');
    if (split.length < 2) return;

    final notiID = split[0];
    final notiCategory = split[1];

    if (!mounted) return;

    if (notiCategory == 'live') {
      enterNotificationClick = false;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubeLiveVideoDetailsActivityFromNotification(int.parse(notiID)),
        ),
        ModalRoute.withName('/home'),
      );
    } else if (notiCategory == 'news') {
      enterNotificationClick = false;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => NewsFeedDetailsActivity(int.parse(notiID)),
        ),
        ModalRoute.withName('/home'),
      );
    } else {
      debugPrint('Unknown payload category: $payload');
    }
  }

  // (Obsolete now, kept only if you still want a UI alert).
  // Not used by flutter_local_notifications v19+ initialization.
  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  // ---------- STREAM/BUILD ----------

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RemoteMessage?>(
      initialData: null,
      stream: _messageStream.messageStream,
      builder: (context, snapshot) {
        final msg = snapshot.data;
        if (msg != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _handleRemoteMessage(msg));
          _messageStream.addMessage(null);
        }
        return widget.child;
      },
    );
  }

  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final isSuccessOpened = prefs.getBool('SuccessIsOpened') ?? false;

    final respond = message.data['respond'];
    if (respond == 'Live') {
      final videoID = message.data['ItemID'];
      if (videoID != null && videoID.toString().isNotEmpty) {
        if (!ONLUNCH) {
          ONLUNCH = true;
          enterNotificationClick = true;
          await _showLiveNotification(
            message.notification?.title ?? '',
            message.notification?.body ?? '',
            videoID,
            'live',
          );
        } else {
          ONLUNCH = false;
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => YoutubeLiveVideoDetailsActivityFromNotification(int.parse(videoID)),
            ),
            ModalRoute.withName('/home'),
          );
        }
      }
    } else if (respond == 'News') {
      final newsID = message.data['ItemID'];
      if (newsID != null && newsID.toString().isNotEmpty) {
        if (!ONLUNCH) {
          ONLUNCH = true;
          enterNotificationClick = true;
          await _showNewsNotification(
            message.notification?.title ?? '',
            message.notification?.body ?? '',
            newsID,
            'news',
          );
        } else {
          ONLUNCH = false;
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => NewsFeedDetailsActivity(int.parse(newsID))),
            ModalRoute.withName('/home'),
          );
        }
      }
    } else {
      final newMessage = message.data['Message'];
      if (newMessage != null && newMessage.toString().isNotEmpty) {
        await _showNotification(
          message.notification?.title ?? '',
          message.notification?.body ?? '',
          '',
        );
        if (!isSuccessOpened && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => NotificationDetailsActivity(newMessage)),
            ModalRoute.withName('/home'),
          );
        }
      }
    }
  }
  Future<void> _ensureAndroidNotificationPermission() async {
  // Pour Android 13+ (Tiramisu), Permission.notification est la runtime-permission.
  final status = await Permission.notification.status;

  if (status.isDenied || status.isRestricted || status.isLimited) {
    await Permission.notification.request();
  } else if (status.isPermanentlyDenied) {
    // Optionnel : ouvrir les réglages
    // await openAppSettings();
  }
}

}
