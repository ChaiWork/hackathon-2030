import 'package:flutter/material.dart';
import 'package:vitalife_asistant/olddesign/result_screen.dart';
import 'service/gemini_service.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  TextEditingController symptomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Symptoms")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Describe your symptoms", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            TextField(
              controller: symptomController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Example: fever, chest pain, headache",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Analyze Symptoms"),
              onPressed: () async {
                var result = await GeminiService.analyzeSymptoms(
                  symptomController.text,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(
                      symptoms: symptomController.text,
                      result: result["result"],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
