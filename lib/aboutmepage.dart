import 'package:flutter/material.dart';
import 'package:flutter_application/loginpage.dart';
import 'package:flutter_application/main.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
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

  Widget SignOutButton() {
    return ElevatedButton(onPressed: signOut, child: Text("Log out"));
  }

  void signOut() async {
    auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginInPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50),
            Back(),
            Row(
              children: <Widget>[
                Icon(Icons.person),
                Text("About Me"),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Name"),
                Container(height: 20, width: 100, color: Colors.purple),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Age"),
                Container(height: 20, width: 100, color: Colors.purple),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Sex"),
                Container(height: 20, width: 100, color: Colors.purple),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Height"),
                Container(height: 20, width: 100, color: Colors.purple),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Weight"),
                Container(height: 20, width: 100, color: Colors.purple),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Race"),
                Container(height: 20, width: 100, color: Colors.purple),
              ],
            ),
            SignOutButton(),
          ],
        ),
      ),
    );
  }
}
