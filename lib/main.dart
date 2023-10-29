import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocs_tracker/screens/launch.dart';
import 'package:ocs_tracker/utils/api.dart';
import 'package:ocs_tracker/utils/background.dart';

class MyHttpOverrides extends HttpOverrides {
  // https://stackoverflow.com/a/61312927
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final api = ApiProvider();
  initializeService();
  // await api.credentialProvider.logout();
  runApp(MyApp(api: api));
}

class MyApp extends StatelessWidget {
  final ApiProvider api;
  const MyApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCS Tracker App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: LaunchScreen(api: api),
    );
  }
}
