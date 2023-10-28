import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ocs_tracker/utils/api.dart';
import 'package:url_launcher/url_launcher.dart';

class Companies extends StatefulWidget {
  final ApiProvider api;
  const Companies({super.key, required this.api});

  @override
  State<Companies> createState() => _CompaniesState();
}

class _CompaniesState extends State<Companies> {
  List<dynamic> companies = [];

  Future<void> initNotifs() async {
    final _companies =
        jsonDecode(await widget.api.read("OCS_COMPANIES") ?? "[]");
    print(_companies);
    setState(() => companies = _companies);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.api.getNotifications().then((_) => initNotifs());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: companies
          .map((e) => ListTile(
                title: Text(e["company_name"]),
                subtitle: Text(e["designation"]),
                onTap: () => launchUrl(Uri.https("ocs.iitd.ac.in",
                    "/portal/view-jnf?code=${e["profile_code"]}&secret=${e["secret"]}")),
              ))
          .toList(),
    );
  }
}
