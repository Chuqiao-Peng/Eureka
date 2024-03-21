import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application/reportlistpage.dart';
import 'package:flutter_application/newspage.dart';
import 'package:flutter_application/settingspage.dart';
import 'package:flutter_application/weeklyreportpage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map> newsData;
  late User user;

  // Tells the page what to do when it first opens
  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
    newsData = getNewsInfo();
  }

  Future<Map> getNewsInfo() async {
    try {
      String link = 'http://18.223.255.251:5000/newsinfo';
      final response = await http.get(Uri.parse(link));
      final Map<String, dynamic> newsData = jsonDecode(response.body);

      // print(newsData);

      return newsData;
    } catch (e) {
      return {};
    }
  }

  void navigateToWeeklyReportPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => WeeklyReportPage()));
  }

  void navigateToNewsPage(Map<String, dynamic> newsData) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NewsPage(newsData: newsData)));
  }

  void navigateToSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  Widget CustomGestureDetector(Map<String, dynamic> newsData) {
    return GestureDetector(
      onTap: () {
        navigateToNewsPage(newsData);
      },
      child: Container(
        child: Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(newsData["image"],
                    fit: BoxFit.cover, width: 1000.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> triggerDevice() async {
    String link =
        'https://api.particle.io/v1/devices/e00fce684219e0e249d5bc42/readECG?access_token=40c9617030f65832904eb99528de3da5e7ebfe66';
    http.post(Uri.parse(link));
    return "Sent Request";
  }

  void SubmitDummyValues() async {


    DateTime date = DateTime.now();
    date = DateTime(date.year, 2, 18);

    int weekOfYear = date.weekday == DateTime.sunday
        ? date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7 + 1
        : date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7;
    String docIDweek = "week" + weekOfYear.toString();

    final db = await FirebaseFirestore.instance; // Connect to database

    // Checks to see if week exists
    final weekExists = await db
        .collection("Users")
        .doc(user.uid)
        .collection("weekly_reports")
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          if (docSnapshot.id == docIDweek) {
            return true;
          }
        }
        return false;
      },
      onError: (e) => print("Error completing: $e"),
    );

    final weekInfo = {
      "warnings": 0
    };
    if (!weekExists) {
      await db
          .collection("Users")
          .doc(user.uid)
          .collection("weekly_reports") // create colletion for weeks
          .doc(docIDweek)
          .set(weekInfo); // Add warnings field
    }

    final reportInfo = {
      "signals": [1, 2, 3, 4, 5, 6]
    };
    await db
        .collection("Users")
        .doc(user.uid)
        .collection("weekly_reports")
        .doc(docIDweek)
        .collection("reports")
        .doc(date.toString())
        .set(reportInfo);
  }

  Widget DianoseNow() {
    return Container(
      width: 300,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Adjust the value to control the roundness
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.all(16.0)),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: SubmitDummyValues,
        child: Text(
          "Diagnose Now",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget CheckReport() {
    return Container(
      width: 300,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Adjust the value to control the roundness
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.all(16.0)),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: navigateToWeeklyReportPage,
        child: Text(
          "Check Report",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget NavigatetoSettingsButton() {
    return Container(
      width: 300,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Adjust the value to control the roundness
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.all(16.0)),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: navigateToSettings,
        child: Text(
          "Navigate to Settings",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget NewsCarousel(List<Widget> news_cards) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          height: 370,
          autoPlay: true,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
        ),
        items: news_cards,
      ),
    );
  }

  Widget NewsSection() {
    return FutureBuilder(
        future: newsData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // some other thing we need to do before return the carousel
            Map newsInfo = snapshot.data as Map;
            List news = newsInfo.keys.toList();
            List<Widget> newsCards = [];
            for (int i = 0; i < news.length; i++) {
              newsCards.add(CustomGestureDetector(newsInfo[news[i]]));
            }
            return NewsCarousel(newsCards);
          } else {
            return Text("Something went wrong...");
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 60),
            Text(
              "Σureka",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 80,
              ),
            ),
            SizedBox(height: 20),
            DianoseNow(),
            SizedBox(height: 20),
            CheckReport(),
            SizedBox(height: 20),
            NavigatetoSettingsButton(),
            SizedBox(height: 20),
            NewsSection(),
          ],
        ),
      ),
    );
  }
}
