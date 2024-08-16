import 'dart:async';
import 'dart:convert';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:Eureka_HeartGuard/newspage.dart';
import 'package:Eureka_HeartGuard/reportpage.dart';
import 'package:Eureka_HeartGuard/settingspage.dart';
import 'package:Eureka_HeartGuard/weeklyreportpage.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Eureka_HeartGuard/main.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // ============= [HEALTH] =============
  List<HealthDataPoint> _healthDataList = [];

  // Or specify specific types
  static final types = [HealthDataType.ELECTROCARDIOGRAM];

  // Set up corresponding permissions
  // READ only
  List<HealthDataAccess> get permissions =>
      types.map((e) => HealthDataAccess.READ).toList();

  // ====================================

  // Tells the page what to do when it first opens
  @override
  void initState() {
    // configure the health plugin before use.
    Health().configure(useHealthConnectIfAvailable: true);
    super.initState();
    user = auth.currentUser!;
    newsData = getNewsInfo();

    authorize();
  }

  // ================================== [HEALTH] ==================================
  // Authorize, i.e. get permissions to access relevant health data.
  Future<void> authorize() async {
    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Check if we have health permissions
    bool? hasPermissions =
        await Health().hasPermissions(types, permissions: permissions);
    print(hasPermissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;


    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized = await Health()
            .requestAuthorization(types, permissions: permissions);
        print(authorized);
        print("permission received...");
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }

    // setState(() => _state =
    //     (authorized) ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
  }

  // Fetch data points from the health plugin and show them in the app.
  Future<void> presentHealthKitData() async {
    // setState(() => _state = AppState.FETCHING_DATA);

    // get data within the last 24 hours
    final date = DateTime.now();
    final yesterday = date.subtract(Duration(hours: 24));

    // Clear old data points
    _healthDataList.clear();

    try {
      // fetch health data
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: types,
        startTime: yesterday,
        endTime: date,
      );

      debugPrint('Total number of data points: ${healthData.length}. '
          '${healthData.length > 100 ? 'Only showing the first 100.' : ''}');

      // save all the new data points (only the first 100)
      _healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
    } catch (error) {
      debugPrint("Exception in getHealthDataFromTypes: $error");
    }

    if (_healthDataList.length == 0) {
      print("No recent ecg data");
      alertNoECGData(context);
      return;
    }

    // filter out duplicates
    _healthDataList = Health().removeDuplicates(_healthDataList);

    // _healthDataList.forEach((data) => debugPrint(toJsonString(data)));
    // _healthDataList.forEach((data) => print(toJsonString(data)));
    String json_string_data = toJsonString(_healthDataList[0]);
    // print(_healthDataList[0]);
    // print(json_string_data);
    // print(json.decode(json_string_data).keys);
    // print(json.decode(json_string_data)["value"].keys);
    // print(json.decode(json_string_data)["value"]["voltage_values"]);

    List volt_values =
        json.decode(json_string_data)["value"]["voltage_values"] as List;
    // print(volt_values);

    List<double> voltages = [];
    for (int i = 0; i < volt_values.length; i++) {
      // print("Voltage: " + volt_values[i]["voltage"].toString() + "   Time Elapsed: " + volt_values[i]["time_since_sample_start"].toString());
      voltages.add(volt_values[i]["voltage"] as double);
    }

    // Values for sample frequecy and ecg volts array
    double sampling_frequency =
        json.decode(json_string_data)["value"]["sampling_frequency"];
    print(sampling_frequency);
    print(voltages);

    // Send values to server
    String reportID = DateTime.now().toString();

    String link = "http://18.223.255.251:5000/healthkit_classifier";
    Map data = {
      'userID': user.uid,
      'reportID': reportID,
      'sampling_frequency': sampling_frequency,
      'ecg_signals': voltages
    };
    var body = json.encode(data);

    final response = http.post(Uri.parse(link),
        headers: {"Content-Type": "application/json"}, body: body);
    print("successfully sent http post request...");

    print(response);

    countDownDisplay(context, reportID);

    // update the UI to display the results
    // setState(() {
    //   _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    // });
  }

  Widget AuthorizeBtn() {
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
        onPressed: authorize,
        child: Text(
          "Authorize",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget DiagnoseNowHK() {
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
        onPressed: presentHealthKitData,
        child: Text(
          "Retrieve ECG Data",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void alertNoECGData(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("No Recent Data"),
      content: Text(
          "Please go to Heart in your Health app and record your elecrocardiogram. "),
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

  // =================================================================

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

  Widget DiagnoseNow() {
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
            presentHealthKitData();
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

      await http.post(Uri.parse(link),
          headers: {"Content-Type": "application/json"}, body: body);

      countDownDisplay(context, reportID);
    } else {
      showWarningPopUp(context);
    }
  }

  void showWarningPopUp(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Ok"),
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
          // height: 300,
          color: const Color.fromRGBO(197, 202, 233, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NewsCarousel(newsCards),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: NewsIndicator(news.length),
              ),
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
            DiagnoseNow(),
            SizedBox(height: 160),
            FutureNewsSection(),
          ],
        ),
      ),
    );
  }
}
