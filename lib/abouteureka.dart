import 'package:flutter/material.dart';

class AboutEureka extends StatefulWidget {
  const AboutEureka({super.key});

  @override
  State<AboutEureka> createState() => _AboutEurekaState();
}

class _AboutEurekaState extends State<AboutEureka> {
  Widget BackButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Color.fromRGBO(57, 73, 171, 1)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 25),
          child: BackButton(context),
        ),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 5),
            Text(
              "Σureka",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                  color: const Color.fromRGBO(57, 73, 171, 1)),
            ),
            Text(
              "Version v1.0.0 (3)",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                "Eureka HeartGuard teaches users about ways to manage their heart health and shows a breakdown of electrocardiogram signals that can be used to inform the user when there might be irregularities in their heartbeats. The app educates users about heart health and overall well-being. Users can access past electrocardiogram signals and stay informed about electrocardiography and relevant heart health news.",
              style: TextStyle(
                  fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                  "Disclaimer: The app is intended for informational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Users should always consult with a qualified healthcare provider before making any medical decisions based on information obtained from this app.",
              ),
            ),
          ],
        ),
      ),
   );
  }
}