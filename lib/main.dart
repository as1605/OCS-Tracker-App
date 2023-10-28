import 'package:flutter/material.dart';
import 'package:ocs_tracker/screens/launch.dart';
import 'package:ocs_tracker/utils/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiProvider();
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
