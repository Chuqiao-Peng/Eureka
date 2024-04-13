import 'package:flutter/material.dart';
import 'package:flutter_application/homepage.dart';
import 'package:flutter_application/weeklyreportpage.dart';
import 'package:flutter_application/aichatpage.dart';
import 'package:flutter_application/settingspage.dart';
import 'package:flutter_application/my_flutter_app_icons.dart';

int selectedIndex = 0;

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  static final List<Widget> pages = <Widget>[
    const HomePage(),
    const WeeklyReportPage(),
    const AIChatPage(),
    const SettingsPage(),
  ];

  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.robot),
            label: "AI Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromRGBO(57, 73, 171, 1),
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: selectPage,
      ),
    );
  }
}
