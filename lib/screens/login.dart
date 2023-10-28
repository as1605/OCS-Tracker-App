import 'package:flutter/material.dart';
import 'package:ocs_tracker/screens/launch.dart';
import 'package:ocs_tracker/utils/as1605.dart';
import 'package:ocs_tracker/utils/api.dart';

class LoginScreen extends StatefulWidget {
  final ApiProvider api;
  const LoginScreen({super.key, required this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String kerberos = "";
  String password = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                    decoration:
                        const InputDecoration(hintText: 'Enter username'),
                    onSaved: (String? value) => kerberos = value ?? ""),
                TextFormField(
                    obscureText: true,
                    decoration:
                        const InputDecoration(hintText: 'Enter password'),
                    onSaved: (String? value) => password = value ?? ""),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      _formKey.currentState!.save();
                      const SnackBar(content: Text('Logging in'));

                      await widget.api.credentialProvider.setPass(password);

                      await widget.api.credentialProvider.setUser(kerberos);

                      await widget.api.credentialProvider.login();
                      widget.api.credentialProvider
                          .checkLogged()
                          .then((check) => {
                                if (!check)
                                  {as1605.popup(context, title: "Login Failed")}
                                else
                                  {
                                    as1605.navReplace(context,
                                        (_) => LaunchScreen(api: widget.api))
                                  }
                              });
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
