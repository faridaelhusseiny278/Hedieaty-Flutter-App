import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hedieatyfinalproject/Controllers/user_controller.dart';
import '../main.dart';
import 'signup_screen.dart';
import '../database.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  bool testing;
  LoginScreen({this.testing = false});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserController userController = UserController();
  String? emailError;


  Future<void> _validateEmail(String email) async {
    setState(() {
      emailError = null; // Reset error
    });

    // Trim the email to remove leading/trailing spaces
    String trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      setState(() {
        emailError = 'Email cannot be empty';
      });
    } else if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(trimmedEmail)) {
      setState(() {
        emailError = 'Enter a valid email address';
      });
    }
  }


  Future<void> _login() async {
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showError("Please fill in both email and password.");
        return;
      }

      final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("Users");
      // remove white spaces and lower the emailcontroller.text
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      DataSnapshot snapshot = await _dbRef.get();

      if (snapshot.value != null) {
        final email = user.user?.email;

        if (snapshot.value is Map) {
          final users = Map<dynamic, dynamic>.from(snapshot.value as Map);
          final userKey = users.keys.firstWhere(
                (key) => users[key]['email'] == email,
            orElse: () => null,
          );
          int userid = await userController.getUserIdByEmailFromFirebase(email!);
          // call get user by id for friends
          Map<String, dynamic>? user= await userController.getUserByIdforFriends(userid);

          if (userKey != null) {
            print("now passing user map $user  to main screen");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(userId: userKey, testing: widget.testing, user: user!),
              ),
            );
          }
        } else if (snapshot.value is List) {
          final users = snapshot.value as List;
          for (var user in users) {
            if (user != null && user['email'] == email) {
              print("now passing user list $user  to main screen");
              print("user type is ${user.runtimeType}");
              // convert the user to map
              final usermap = Map<String, dynamic>.from(
                user.map(
                      (key, value) => MapEntry(
                    key.toString(), // Convert keys to String
                    value,          // Keep values as dynamic
                  ),
                ),
              );

              print("now passing user map $usermap  to main screen");
              print("now type of user map is ${usermap.runtimeType}");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(userId: user['userid'], testing: widget.testing, user: usermap!),
                ),
              );
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(_handleFirebaseAuthError(e));
    } catch (e) {
      _showError("An unexpected error occurred. Please try again.");
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return "Incorrect email or password. Please try again.";
      case 'network-request-failed':
        return "Network error. Please check your internet connection.";
      default:
        return "Authentication failed. Please try again.";
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensures the container takes up the full screen height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height, // Minimum height matches screen height
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Login to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    onChanged: (email) => _validateEmail(email),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email",
                      errorText: emailError,
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.email, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    color: Colors.white38,
                    thickness: 1.0,
                    indent: 40,
                    endIndent: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "or connect with",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.facebook, color: Colors.white),
                        onPressed: () {
                          // Add Facebook Login Logic
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.mail, color: Colors.white),
                        onPressed: () {
                          // Add Google Login Logic
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
