// Name: Julian Qapo
// Date: November 16th, 2025
// Description: main entry point for note my app with route definitions

import 'package:flutter/material.dart';
import 'package:note_app/notes.dart';
import 'package:note_app/signup_signin.dart';
import 'package:note_app/welcome.dart';
import 'package:note_app/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//################## DONE ##################

// import 'pages/calculation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        "/notes": (context) => UserNotesScreen(),
        "/auth": (context) => AuthScreen(),
        "/settings": (context) => SettingsScreen(),
        // '/calculate': (context) => const CalculationScreen(),
      },
    );
  }
}
