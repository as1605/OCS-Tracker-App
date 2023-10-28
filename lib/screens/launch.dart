import 'package:flutter/material.dart';
import 'package:ocs_tracker/screens/home.dart';
import 'package:ocs_tracker/screens/login.dart';
import 'package:ocs_tracker/utils/api.dart';

class LaunchScreen extends StatelessWidget {
  final ApiProvider api;
  const LaunchScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: api.credentialProvider.checkLogged(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print({snapshot});
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data) {
              return HomeScreen(api: api);
            } else {
              return LoginScreen(api: api);
            }
          } else {
            return Scaffold(
                appBar: AppBar(title: const Text("OCS Tracker")),
                body:
                    const Center(child: CircularProgressIndicator.adaptive()));
          }
        });
  }
}
