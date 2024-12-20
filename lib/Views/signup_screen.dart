import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hedieatyfinalproject/Controllers/user_controller.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'login_screen.dart';
import '../Models/user_model.dart';
import '../Controllers/user_controller.dart';
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("Users");
  final UserController user_controller = UserController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? emailError;
  String? phoneError;
  String? nameError;
  String? addressError;
  String? passwordError;

  void _validateName(String name) {
    setState(() {
      if (name.isEmpty) {
        nameError = 'Name cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z\s]{3,50}$").hasMatch(name)) {
        nameError = 'Enter a valid name (3-50 alphabetic characters)';
      } else {
        nameError = null;
      }
    });
  }
  void _validateAddress(String address) {
    setState(() {
      if (address.isEmpty) {
        addressError = 'Address cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z0-9\s,.-]{5,100}$").hasMatch(address)) {
        addressError = 'Enter a valid address (5-100 characters, no special characters)';
      } else {
        addressError = null;
      }
    });
  }


  Future<void> _validateEmail(String email) async {
    DatabaseService dbService = DatabaseService();
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
    } else if (await user_controller.checkEmail(trimmedEmail, null)) {
      setState(() {
        emailError = 'Email already exists';
      });
    }
  }

  Future<void> _validatePhoneNumber(String phoneNumber) async {
    DatabaseService dbService = DatabaseService();
    setState(() {
      phoneError = null; // Reset error
    });
    if (phoneNumber.isEmpty) {
      setState(() {
        phoneError = 'Phone number cannot be empty';
      });
    } else if (!RegExp(r"^\+\d{10,15}$").hasMatch(phoneNumber)) {
      setState(() {
        phoneError = 'Enter a valid phone number starting with + and has 10-15 digits';
      });
    } else if (await user_controller.checkPhoneNumber(phoneNumber,null)) {
      setState(() {
        phoneError = 'Phone number already exists';
      });
    }
  }
  // validate password
  void _validatePassword(String password) {
    setState(() {
      if (password.isEmpty) {
        setState(() {
          passwordError = 'Password cannot be empty';
        });
      } else if (password.length < 8) {
        setState(() {
          passwordError = 'Password must be at least 8 characters';
        });
      } else {
        setState(() {
          passwordError = null;
        });
      }
    });
  }

  Future<int> _getNewUserId() async {
    DataSnapshot snapshot = await _dbRef.get();
    if (snapshot.value != null) {
      if (snapshot.value is Map) {
        print("Snapshot value is a Map");
        final users = Map<dynamic, dynamic>.from(snapshot.value as Map);
        print("Users: $users");
        return users.keys.isEmpty ? 1 : users.keys.last + 1;
      } else if (snapshot.value is List) {
        print("Snapshot value is a List");
        print("Length: ${(snapshot.value as List).length}");
        return (snapshot.value as List).length;
      }
    }
    return 1;
  }

  Future<void> _signup() async {
    try {
      final newUserId = await _getNewUserId();
      print("New User ID: $newUserId");
      UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("User created: ${user.user!.uid}");

      await _dbRef.child(newUserId.toString()).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phonenumber': _phoneController.text,
        'address': _addressController.text,
        'userid': newUserId,
        "notification_preferences": ["Push Notifications"],
        'imageurl': "assets/istockphoto-1296058958-612x612.jpg",
        'events': [],
        'friends': []

      });

      await user_controller.addUser(newUserId, _nameController.text,
          _emailController.text, _phoneController.text, _addressController.text, ["Push Notifications"], "assets/istockphoto-1296058958-612x612.jpg");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print("Signup Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        onChanged: (name) => _validateName(name),
                        decoration: InputDecoration(
                          labelText: "Name",
                          errorText: nameError,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        onChanged: (phone) => _validatePhoneNumber(phone),
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          errorText: phoneError,
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressController,
                        onChanged: (address) => _validateAddress(address),
                        decoration: InputDecoration(
                          labelText: "Address",
                          errorText: addressError,
                          prefixIcon: const Icon(Icons.home),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        onChanged: (email) => _validateEmail(email),
                        decoration: InputDecoration(
                          labelText: "Email",
                          errorText: emailError,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        onChanged: (password) => _validatePassword(password),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          errorText: passwordError,
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (nameError == null &&
                              emailError == null &&
                              phoneError == null &&
                              addressError == null && passwordError == null&&
                              _nameController.text.isNotEmpty && _phoneController.text.isNotEmpty && _addressController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                            _signup();
                          }
                          else if (_nameController.text.isEmpty) {
                            setState(() {
                              nameError = 'Name cannot be empty';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all the fields"),
                                ),
                              );
                            });
                          }
                          else if (_phoneController.text.isEmpty) {
                            setState(() {
                              phoneError = 'Phone number cannot be empty';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all the fields"),
                                ),
                              );
                            });
                          }
                          else if (_addressController.text.isEmpty) {
                            setState(() {
                              addressError = 'Address cannot be empty';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all the fields"),
                                ),
                              );
                            });
                          }
                          else if (_emailController.text.isEmpty) {
                            setState(() {
                              emailError = 'Email cannot be empty';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all the fields"),
                                ),
                              );
                            });
                          }
                          else if (_passwordController.text.isEmpty) {
                            setState(() {
                              passwordError = 'Password cannot be empty';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all the fields"),
                                ),
                              );
                            });
                          }
                            else if (nameError != null || emailError != null || phoneError != null || addressError != null || passwordError != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fix the errors"),
                                ),
                              );
                            }
                          },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text("Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
