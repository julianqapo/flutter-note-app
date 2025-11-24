// Name: Julian Qapo
// Date: November 16th, 2025
// Description: welcome page

//################## DONE ##################

import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset("./assets/note.jpg"),

                const Text(
                  'Your Favourite note app.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 30,
                    //  bold font weight
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40.0),

                // navigation button (sign in & sign up)
                ElevatedButton(
                  // on click, redirect to auth screen
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    // rounded corners
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.fromLTRB(40, 14, 40, 14),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // add space
                const SizedBox(height: 40.0),
                const Text(
                  'By tapping "Get started," you agree to our Terms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
