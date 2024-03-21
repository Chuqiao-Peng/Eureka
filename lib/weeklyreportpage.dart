import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/main.dart';

class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  late User user;
  late Future<List<QueryDocumentSnapshot>> weeklyReports;

  @override
  void initState() {
    super.initState();

    user = auth.currentUser!;
    weeklyReports = QueryWeeklyReports();
  }

  Future<List<QueryDocumentSnapshot>> QueryWeeklyReports() async {
    final db = await FirebaseFirestore.instance; // Connect to database

    List<QueryDocumentSnapshot> weeklyReportsList = [];

    // Ask the database for reports
    await db
        .collection("Users")
        .doc(user.uid)
        .collection("weekly_reports")
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          weeklyReportsList.add(docSnapshot);
          // print(docSnapshot.data());
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    return weeklyReportsList;
  }

  Widget FutureTopWindow() {
    return FutureBuilder(
        future: weeklyReports,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // render the report list on screen
            List reportList = snapshot.data as List;
            QueryDocumentSnapshot doc = reportList[0];
            Map data = doc.data() as Map;
            int warnings = data["warnings"];

            return TopWindow(warnings);
          } else {
            return Text("An error occurred. Could not get warnings");
          }
        });
  }

  Widget TopWindow(int warnings) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Most Recent Report"),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(7.0),
              child: Container(
                height: 200,
                color: Colors.purple,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              warnings.toString(),
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "warnings",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: null,
                              child: Text("View more"),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.circle_outlined,
                          size: 80,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget FutureReportList() {
    return FutureBuilder(
        future: weeklyReports,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // render the report list on screen
            List reportList = snapshot.data as List;
            return ReportList(reportList);
          } else {
            return Text("An error occurred. Could not get report list");
          }
        });
  }

  Widget ReportList(List reportList) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Past Reports"),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(7.0),
              child: Container(
                height: 200,
                child: ListView(
                  children: generateReportRows(reportList),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateReportRows(List reportList) {
    List<Widget> reportRows = [];
    for (int i = 0; i < reportList.length; i++) {
      reportRows.add(ReportRow(reportList[i].id));
    }
    return reportRows;
  }

  Widget ReportRow(String reportName) {
    return GestureDetector(
      onTap: () {
        null;
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 5.0),
          color: Color.fromARGB(255, 223, 173, 231),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.settings),
              Text(reportName),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ],
          )),
    );
  }

  Widget Back() {
    return Container(
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Row(
          children: <Widget>[
            Icon(Icons.arrow_back),
            Text("Back"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 70),
            Back(),
            FutureTopWindow(),
            FutureReportList(),
          ],
        ),
      ),
    );
  }
}
