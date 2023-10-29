import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ocs_tracker/main.dart';
import 'package:ocs_tracker/utils/api.dart';

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
var notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'OCS Tracker', // title
    description: 'This channel is used for new companies.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidImplementation?.createNotificationChannel(channel);
  await androidImplementation?.requestNotificationsPermission();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: notificationChannelId,
      // this must match with notification channel you created above.
      initialNotificationTitle: 'OCS Tracker',
      initialNotificationContent:
          'Initializing... This app will check for new companies every 10 minutes',
      foregroundServiceNotificationId: notificationId,
    ),
  );
  print("AYYYYy");
}

Future<(String, int)> getText() async {
  HttpOverrides.global = MyHttpOverrides();
  final api = ApiProvider();

  final isUser = await api.credentialProvider.getUser() ?? "";
  if (isUser == "") {
    return ("Please login with kerberos and OCS password", -1);
  }

  final isLogged = await api.credentialProvider.checkLogged();
  if (!isLogged) {
    await api.credentialProvider.login();
    final nowLogged = await api.credentialProvider.checkLogged();
    if (!nowLogged) {
      return ("Invalid credentials", -1);
    }
  }

  final notifs = await api.getNotifications();

  return (
    "${notifs.length} new companies! ${notifs.map((e) => "${e["company_name"]} (${e["designation"]})").join(" | ")}",
    notifs.length
  );
}

Future<void> checkNotif(FlutterLocalNotificationsPlugin plugin) async {
  final (text, num) = await getText();
  if (num > 0) {
    notificationId++;
  }
  plugin.show(
    notificationId,
    'OCS Tracker',
    text,
    const NotificationDetails(
      android: AndroidNotificationDetails(notificationChannelId, 'OCS Tracker',
          icon: 'ic_bg_service_small',
          onlyAlertOnce: true,
          priority: Priority.max,
          importance: Importance.max),
    ),
  );
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  checkNotif(flutterLocalNotificationsPlugin);

  Timer(const Duration(minutes: 1),
      () => checkNotif(flutterLocalNotificationsPlugin));

  Timer.periodic(const Duration(minutes: 10),
      (_) => checkNotif(flutterLocalNotificationsPlugin));
}
