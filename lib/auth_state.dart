// Name: Julian Qapo
// Date: November 16th, 2025
// Description: check auth state change and redirect

//################## DONE ##################

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notes.dart';
import 'welcome.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // initialize firebaseauth
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // check connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            // loading state (show circular progress)
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // the user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // render notes scree
          return UserNotesScreen();
        }

        // else, note logged in, render welcome screen
        return WelcomeScreen();
      },
    );
  }
}
