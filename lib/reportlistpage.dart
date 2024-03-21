import 'package:flutter/material.dart';
import 'package:flutter_application/reportpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/main.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}


class _ReportListPageState extends State<ReportListPage> {
  late Future<List> reportList;   // Variable to hold the list of reports
  late User user;

  // Tells the page what to do when it first opens
  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
    reportList = QueryReportList(); // Asking the db for a list of the user's reports
  }

  Future<List> QueryReportList() async {
    final db = await FirebaseFirestore.instance;  // Connect to database
    List reportList = [];
    
    // Ask the database for reports
    await db.collection("Users").doc(user.uid).collection("Reports").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          reportList.add(docSnapshot.id);
          // print(docSnapshot.data());
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    return reportList;
  }

  void navigateToReportPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ReportPage()));
  }

  Widget ReportRow(String reportName) {
    return GestureDetector(
      onTap: () {
        navigateToReportPage();
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

  List<Widget> generateReportRows(List reportList) {
    List<Widget> reportRows = [];
    for (int i = 0; i < reportList.length; i++)
    {
      reportRows.add(ReportRow(reportList[i]));
    }
    return reportRows;
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

  Widget FutureReportList() {
    return FutureBuilder(future: reportList, builder: (context, snapshot) {
      if(snapshot.hasData) {
        // render the report list on screen
        List reportList = snapshot.data as List;
        return ReportList(reportList);      
      } else {
        return Text("An error occurred. Could not get report list");
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Icon(
            Icons.file_copy,
            color: Colors.purple,
          ),
        ),
        title: Text(
          "Personal Reports",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25.0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              height: 20,
              color: Colors.grey,
            ),
            FutureReportList(),
          ],
        ),
      ),
    );
  }
}
