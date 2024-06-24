import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:Eureka_HeartGuard/newspage.dart';
import 'package:Eureka_HeartGuard/reportpage.dart';
import 'package:Eureka_HeartGuard/settingspage.dart';
import 'package:Eureka_HeartGuard/weeklyreportpage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Eureka_HeartGuard/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map> newsData;
  late User user;
  // Initialize the index for the news carousel
  int _currentCard = 0;

  late Timer _timer;

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

  Widget CarouselCards(Map<String, dynamic> newsData) {
    String article_headline = newsData["article_title"];
    if (newsData["article_title"].length >= 20) {
      article_headline = newsData["article_title"].substring(0, 20) + "...";
    }
    String article_brief = newsData["article_content"].substring(0, 20) + "...";
    String image_url = newsData["image"];

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(article_headline,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              Wrap(
                children: <Widget>[
                  Text(article_brief),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(14.0)),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromRGBO(121, 134, 203, 1)),
                ),
                onPressed: () {
                  navigateToNewsPage(newsData);
                },
                child: Text(
                  "View More",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                child: Image.network(
                  image_url,
                  fit: BoxFit.cover,
                  height: 120.0,
                  width: 120.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> isDataValid() async {
    // Query for user data
    final db = await FirebaseFirestore.instance; // Connect to database

    final user_data = await db.collection("Users").doc(user.uid).get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      },
      onError: (e) => print("Error completing: $e"),
    );

    if (user_data["age"] == "" || user_data["age"] == 0) {
      return false;
    } else if (user_data["sex"] == "" || user_data["sex"] == "?") {
      return false;
    } else if (user_data["height"] == "" || user_data["height"] == 0) {
      return false;
    } else if (user_data["weight"] == "" || user_data["weight"] == 0) {
      return false;
    } else if (user_data["race"] == "" || user_data["race"] == "?") {
      return false;
    }
    return true;
  }

  void diagnoseFunction() async {
    if (await isDataValid()) {
      String reportID = DateTime.now().toString();
      triggerDevice(reportID);
      countDownDisplay(context, reportID);
    } else {
      showWarningPopUp(context);
    }
  }

  void countDownDisplay(BuildContext context, String reportID) {
    late StreamController<int> _events = new StreamController<int>();

    int _counter = 15;
    _events.add(_counter);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        _counter--;
        _events.add(_counter);
      } else {
        _timer.cancel();
        Navigator.of(context).pop();

        // Calculate week id
        DateTime date = DateTime.parse(reportID);
        int weekOfYear = date.weekday == DateTime.sunday
            ? date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7 + 1
            : date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7;
        String weekID = "week" + weekOfYear.toString();

        // Navigate to report page
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ReportPage(weekId: weekID, reportId: reportID)));
      }
    });

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Diagnose Countdown"),
      content: StreamBuilder<int>(
          stream: _events.stream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            return Text(snapshot.data.toString());
          }),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future<int> triggerDevice(String reportID) async {
    String link =
        'https://api.particle.io/v1/devices/e00fce684219e0e249d5bc42/uploadEKGData?access_token=40c9617030f65832904eb99528de3da5e7ebfe66';

    String boron_data = user.uid + "," + reportID;
    Map data = {'args': boron_data};

    var body = json.encode(data);

    var response = await http.post(Uri.parse(link),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print("Successfully triggered sensor to start reading...");
      return 1;
    }
    return 0;
  }

  Widget DianoseNow() {
    return Container(
      width: 350,
      height: 60,
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
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromRGBO(121, 134, 203, 1)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: () {
          if (user.email == "eureka@gmail.com") {
            diagnoseSampleFunction();
          } else {
            diagnoseFunction();
          }
        },
        child: Text(
          "Diagnose Now",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void diagnoseSampleFunction() async {
    if (await isDataValid()) {
      String reportID = DateTime.now().toString();

      String link = "http://18.223.255.251:5000/sample_data_classify";
      Map data = {'reportID': reportID};
      var body = json.encode(data);

      await http.post(Uri.parse(link), headers: {"Content-Type": "application/json"}, body: body);

      countDownDisplay(context, reportID);
    } else {
      showWarningPopUp(context);
    }
  }

  void showWarningPopUp(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Profile Incomplete!"),
      content: Text(
          "Navigate to the \"About Me\" page and fill out your information to begin diagnosis."),
      actions: <Widget>[
        cancelButton,
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Widget NewsCarousel(List<Widget> news_cards) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCard = index;
              });
            }),
        items: news_cards,
      ),
    );
  }

  Widget NewsIndicator(int amtOfCards) {
    List<Widget> circles = [];

    for (int i = 0; i < amtOfCards; i++) {
      if (i == _currentCard) {
        circles.add(Icon(
          size: 15,
          color: const Color.fromRGBO(57, 73, 171, 1),
          Icons.circle,
        ));
      } else {
        circles.add(Icon(
          size: 15,
          color: const Color.fromRGBO(57, 73, 171, 1),
          Icons.circle_outlined,
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: circles,
    );
  }

  Widget FutureNewsSection() {
    return FutureBuilder(
        future: newsData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // some other thing we need to do before return the carousel
            Map newsInfo = snapshot.data as Map;

            return NewsSection(newsInfo);
          } else {
            return Text("Something went wrong...");
          }
        });
  }

  Widget NewsSection(Map newsInfo) {
    List news = newsInfo.keys.toList();
    List<Widget> newsCards = [];
    for (int i = 0; i < news.length; i++) {
      newsCards.add(CarouselCards(newsInfo[news[i]]));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: Container(
          height: 300,
          color: const Color.fromRGBO(197, 202, 233, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NewsCarousel(newsCards),
              NewsIndicator(news.length),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 85),
            Text(
              "Σureka",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                  color: const Color.fromRGBO(57, 73, 171, 1)),
            ),
            SizedBox(height: 50),
            DianoseNow(),
            SizedBox(height: 160),
            FutureNewsSection(),
          ],
        ),
      ),
    );
  }
}
