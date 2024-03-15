import 'package:flutter/material.dart';
import 'package:flutter_application/aboutmepage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void navigateToAboutMePage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AboutMePage()));
  }

  Widget SettingsRow(String settingsName) {
    return GestureDetector(
      onTap: navigateToAboutMePage,
      child: Container(
          margin: const EdgeInsets.only(bottom: 5.0),
          color: Color.fromARGB(255, 223, 173, 231),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.settings),
              Text(settingsName),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("This is the settings page."),
            SettingsRow("About me"),
            SettingsRow("Messages"),
            SettingsRow("Account Security and Privacy"),
            SettingsRow("About Σureka"),
          ],
        ),
      ),
    );
  }
}
