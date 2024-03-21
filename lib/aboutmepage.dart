import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/loginpage.dart';
import 'package:flutter_application/main.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _raceController = TextEditingController();

  late User user;


  @override
    void initState() {
      super.initState();

      user = auth.currentUser!;
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

  Widget SignOutButton() {
    return ElevatedButton(onPressed: signOut, child: Text("Log out"));
  }

  void signOut() async {
    auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginInPage()),
        (route) => false);
  }

  Widget DataInputRow(String dataType, TextEditingController controller) {
    return Row(
              children: <Widget>[
                Text(dataType),
                Container(
                  height: 20,
                  width: 100,
                  color: Colors.purple,
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(8.0),
                      filled: true,
                      fillColor:
                          Colors.white, // Background color of the text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            50.0), // Adjust the value to control the roundness
                        borderSide: BorderSide(
                          color: Colors.purple, // Border color
                          width: 4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(
                          color: Colors.purple, // Border color when focused
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
  }

  Widget SubmitDataButton() {
    return ElevatedButton(onPressed: _updateProfile, child: Text("Update Profile"));
  }

  void _updateProfile() async {
    
    final db = await FirebaseFirestore.instance; // Connect to database

    final data = <String, dynamic> {
      "full_name": _nameController.text,
      "age": _ageController.text,
      "sex": _sexController.text,
      "height": _heightController.text,
      "weight": _weightController.text,
      "race": _raceController.text,
    };  

    // attempt to update the given document with the new data
    await db.collection("Users").doc(user.uid).update(data); 
  
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
            DataInputRow("Name", _nameController),
            DataInputRow("Age", _ageController),
            DataInputRow("Sex", _sexController),
            DataInputRow("Height", _heightController),
            DataInputRow("Weight", _weightController),
            DataInputRow("Race", _raceController),
            SizedBox(height: 40),
            SubmitDataButton(),
            SignOutButton(),
          ],
        ),
      ),
    );
  }
}
