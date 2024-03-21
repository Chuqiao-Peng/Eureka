import 'package:flutter/material.dart';
import 'package:flutter_application/homepage.dart';
import 'package:flutter_application/weeklyreportpage.dart';
import 'package:flutter_application/aichatpage.dart';
import 'package:flutter_application/settingspage.dart';


class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {

  int selectedIndex = 0;

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
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.addchart),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: selectPage,
      ),
    );
  }
}