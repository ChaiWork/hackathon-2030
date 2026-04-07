import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String symptoms;

  final String result;

  const ResultScreen({super.key, required this.symptoms, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical, // or Axis.horizontal

        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Symptoms Entered:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(symptoms),
            SizedBox(height: 30),

            Text(
              "AI Analysis:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(result),
            // Text(
            //   "Risk Level: MEDIUM",
            //   style: TextStyle(fontSize: 22, color: Colors.orange),
            // ),
            // SizedBox(height: 10),
            // Text(
            //   "Recommendation:",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // Text("Visit a clinic within 24 hours for further check."),
          ],
        ),
      ),
    );
  }
}
