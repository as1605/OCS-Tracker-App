import 'package:flutter/material.dart';
import 'package:ocs_tracker/screens/launch.dart';
import 'package:ocs_tracker/screens/notifs.dart';
import 'package:ocs_tracker/utils/as1605.dart';
import 'package:ocs_tracker/utils/api.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  final ApiProvider api;
  const HomeScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home"), actions: [
        ElevatedButton(
            onPressed: () => api.credentialProvider.logout().then((_) =>
                as1605.navReplace(context, (_) => LaunchScreen(api: api))),
            child: const Text('Logout'))
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: Companies(api: api))),
          Center(
              child: TextButton(
                  onPressed: () => launchUrl(
                      Uri.parse('https://github.com/as1605'),
                      mode: LaunchMode.externalApplication),
                  child: RichText(
                      text: TextSpan(children: const [
                    TextSpan(text: "Developed by Aditya Singh "),
                    TextSpan(
                        text: "(as1605)",
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ], style: TextStyle(color: Colors.grey.shade500)))))
        ],
      ),
    );
  }
}
