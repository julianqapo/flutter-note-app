// Name: Julian Qapo
// Date: November 16th, 2025
// Description: auth screen, sign up, sign in and forgot password

//################## DONE ##################

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // monitor change and get text value
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // initialize firebase auth
  final _auth = FirebaseAuth.instance;

  // change screen (log in & log out)
  bool _isLogin = true;

  @override
  void dispose() {
    // dispose to prevent leak memory

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // function to log in or signup since both reuqire email and password
  Future<void> _submitAuthForm() async {
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showErrorSnackBar('Please enter both email and password.');
        return;
      }
      if (_isLogin) {
        // make request to firebase auth, to sign in with email and password
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // redirect to notes screen
        Navigator.of(context).pushReplacementNamed('/notes');
        // sign up
      } else {
        // make request to firebase auth to create account with email and password
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // then sign in with same credintials
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // redirect to note screen
        Navigator.of(context).pushReplacementNamed('/notes');
        _showSuccessSnackBar('Account created and signed in!');
      }
      // catch any error and notify the user
    } on FirebaseAuthException catch (e) {
      // if no error message is returned from firebase auth, display unknown error
      _showErrorSnackBar(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred: $e');
    }
  }

  // forget password (send email to the user to reset password)
  // everything is done by firebase auth
  Future<void> _forgotPassword() async {
    try {
      // check if email field is empty to show error message to the user
      if (_emailController.text.isEmpty) {
        _showErrorSnackBar('Please enter your email to reset the password.');
        return;
      }
      // if not, send email link for the user to reset (email in ####### SPAM ####### folder)
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSuccessSnackBar('Password reset link sent to your email!');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'Error sending reset email.');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred: $e');
    }
  }

  // helper function to display error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
    );
  }

  // helper function to show successful messages
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ########## test start here
    // get user if there is one
    final user = FirebaseAuth.instance.currentUser;
    // get email from user object
    final userEmail = user?.email;

    // if no email, redirect to home page
    if (userEmail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/notes', (route) => false);
      });
      // while updating the state, show circular progress
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // ########## test ends here

    // terany operator (less code than if and else)
    // determine whether the user is trying to login or create an account
    final primaryActionText = _isLogin ? 'Log in' : 'Sign up';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // chaning icon from back arrow to close
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          // redirect to home page
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/', (route) => false),
        ),
        title: const Icon(
          Icons.mode_edit_outline,
          color: Colors.black,
          size: 30,
        ),
        centerTitle: true,
      ),
      body: Center(
        // prevent over flow when the keyboard is shown in the screen
        child: SingleChildScrollView(
          // add padding for style
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          // stack widget on top of each others
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                _isLogin ? 'Sign in to NotesApp' : 'Create your account',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 50),

              // sign in/sign up button
              ElevatedButton(
                onPressed: _submitAuthForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  primaryActionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // add space
              const SizedBox(height: 15),

              // show only if sign in
              if (_isLogin)
                TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  setState(() {
                    // make it not equal to the previous value
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? "Don\'t have an account? Sign up"
                      : 'Already have an account? Log in',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
