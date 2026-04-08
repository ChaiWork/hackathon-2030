import 'package:flutter/material.dart';
import 'package:vitalife_asistant/HealthDashboard.dart';

void main() {
  runApp(VitaApp());
}

class VitaApp extends StatelessWidget {
  const VitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitalife Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HealthDashboard(),
    );
  }
}
