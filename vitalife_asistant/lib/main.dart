// import 'package:flutter/material.dart';
// import 'package:vitalife_asistant/HealthDashboard.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(VitaApp());
// }

// class VitaApp extends StatelessWidget {
//   const VitaApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Vitalife Assistant',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: HealthDashboard(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:vitalife_asistant/screens/auth_screen.dart';
import 'package:vitalife_asistant/screens/home_screen.dart';

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
