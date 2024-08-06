import 'package:flutter/material.dart';
import 'package:Eureka_HeartGuard/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Eureka_HeartGuard/navigationpage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController1 = TextEditingController();
  final _passwordController2 = TextEditingController();

  bool obscureValue1 = true;
  bool obscureValue2 = true;

  void navigateToNavigationPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NavigationPage()));
  }

  void navigateToLoginPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginInPage()));
  }

  Widget NameTextField(String hintValue) {
    return Container(
      height: 35.0,
      width: 350.0,
      child: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8.0),
          hintText: hintValue,
          filled: true,
          fillColor: Colors.white, // Background color of the text field
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                10.0), // Adjust the value to control the roundness
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color
              width: 4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color when focused
              width: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget EmailTextField(String hintValue) {
    return Container(
      height: 35.0,
      width: 350.0,
      child: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8.0),
          hintText: hintValue,
          filled: true,
          fillColor: Colors.white, // Background color of the text field
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                10.0), // Adjust the value to control the roundness
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color
              width: 4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color when focused
              width: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget CustomPasswordField1(String hintValue) {
    return Container(
      height: 35.0,
      width: 350.0,
      child: TextField(
        controller: _passwordController1,
        obscureText: obscureValue1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8.0),
          suffixIcon: IconButton(
            icon: Icon(
              obscureValue1 ? Icons.visibility_off : Icons.visibility,
              color: const Color.fromRGBO(121, 134, 203, 1),
            ),
            onPressed: () {
              setState(() {
                obscureValue1 = !obscureValue1;
              });
            },
          ),
          hintText: hintValue,
          filled: true,
          fillColor: Colors.white, // Background color of the text field
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                10.0), // Adjust the value to control the roundness
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color
              width: 4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color when focused
              width: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget CustomPasswordField2(String hintValue) {
    return Container(
      height: 35.0,
      width: 350.0,
      child: TextField(
        controller: _passwordController2,
        obscureText: obscureValue2,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8.0),
          suffixIcon: IconButton(
            icon: Icon(
              obscureValue2 ? Icons.visibility_off : Icons.visibility,
              color: const Color.fromRGBO(121, 134, 203, 1),
            ),
            onPressed: () {
              setState(() {
                obscureValue2 = !obscureValue2;
              });
            },
          ),
          hintText: hintValue,
          filled: true,
          fillColor: Colors.white, // Background color of the text field
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                10.0), // Adjust the value to control the roundness
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color
              width: 4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: const Color.fromRGBO(121, 134, 203, 1), // Border color when focused
              width: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget WarningWindow()
  {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7.0),
              child: Container(
                height: 80,
                color: Color.fromARGB(255, 239, 239, 114),
                child:
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.warning),
                    ),
                    Expanded(
                      child: Text(
                        "Warning: This app is for informational purposes only; please consult your doctor before making any medical decisions.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ), 
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  void SignUp() async {
    // Create a user account for firebase authentication
    String name_text = _nameController.text;
    String email_text = _emailController.text;
    String password_text = _passwordController2.text;

    // Create an account
    UserCredential cred =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email_text,
      password: password_text,
    );

    final profileInfo = {
      "full_name": name_text,
      "email": email_text,
      "age": 0,
      "sex": "?",
      "height": 0,
      "weight": 0,
      "race": "?",
    };

    // Allocate space for user data in the database
    final db = await FirebaseFirestore.instance; // Connect to database
    await db
        .collection("Users")
        .doc(cred.user?.uid)
        .set(profileInfo); // Creates a user folder in the database

    // final weekInfo = {
    //   "warnings": 0,
    // };
    // await db
    //     .collection("Users")
    //     .doc(cred.user?.uid)
    //     .collection("weekly_reports")
    //     .doc("week11")
    //     .set(weekInfo); // creates weekly report list in user

    // final reportInfo = {
    //   "signals": [1, 2, 3, 4, 5, 6],
    // };
    // await db
    //     .collection("Users")
    //     .doc(cred.user?.uid)
    //     .collection("weekly_reports")
    //     .doc("week11")
    //     .collection("reports")
    //     .doc(DateTime.now().toString())
    //     .set(reportInfo);

    // Navigate to homepage
    navigateToNavigationPage();
  }

    Widget SignUpButton() {
    return Container(
      height: 35.0,
      width: 350.0,
      child: ElevatedButton(
        onPressed: SignUp,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(
              121, 134, 203, 1)), // Background color of the button
          foregroundColor: MaterialStateProperty.all(
              Colors.white), // Text color of the button
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        child: Text('Sign Up'),
      ),
    );
  }

  Widget birthdayDropdown() {
    DateTime date = DateTime.now();

    List months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    String selectedDay = date.day.toString(); // Default today's date
    String selectedMonth = months[date.month - 1];
    String selectedYear = date.year.toString();

    List<DropdownMenuItem<String>> dayItems =
        List<String>.generate(31, (index) => '${index + 1}')
            .map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> monthItems = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> yearItems =
        List<String>.generate(100, (index) => '${DateTime.now().year - index}')
            .map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    return Container(
      width: 350,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          DropdownButton<String>(
            value: selectedDay,
            onChanged: (newValue) {
              setState(() {
                selectedDay = newValue!;
              });
            },
            items: dayItems,
          ),
          DropdownButton<String>(
            value: selectedMonth,
            onChanged: (newValue) {
              setState(() {
                selectedMonth = newValue!;
              });
            },
            items: monthItems,
          ),
          DropdownButton<String>(
            value: selectedYear,
            onChanged: (newValue) {
              setState(() {
                selectedYear = newValue!;
              });
            },
            items: yearItems,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            "Σureka",
            style: TextStyle(
                color: const Color.fromRGBO(57, 73, 171, 1),
                fontWeight: FontWeight.bold,
                fontSize: 26.0),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
              Text(
                "Hi! Welcome",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              Text(
                "Please register below",
                style: TextStyle(
                  color: const Color.fromRGBO(121, 134, 203, 1),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 80),
              NameTextField("Full Name"),
              SizedBox(height: 20),
              EmailTextField("Email or Phone Number"),
              SizedBox(height: 20),
              CustomPasswordField1("Password"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "Password must be at least 6 characters and contain numbers and letters",
                  style: TextStyle(
                    color: const Color.fromRGBO(57, 73, 171, 1),
                    fontSize: 10,
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomPasswordField2("Confirm Password"),
              SizedBox(height: 20),
              birthdayDropdown(),
              SizedBox(height: 40),
              SignUpButton(),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Have an account?",
                      style: TextStyle(
                          color: const Color.fromRGBO(57, 73, 171, 1)),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Log In",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(57, 73, 171, 1)),
                        )),
                  ]),
              SizedBox(height: 30),
              WarningWindow(),
            ],
          ),
        ),
      );
  }
}
