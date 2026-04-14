import 'package:flutter/material.dart';
import 'package:flutter_design_vitalife/screens/auth_screen.dart';
import 'package:flutter_design_vitalife/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7EA0EA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
