import 'dart:html' as html; // Add this import for web support
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examai_flutter/professor/professor_dashboard.dart';
import 'package:examai_flutter/student/student_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyBsFTP5FgFSDjvy59ckkjP796deHYpXLSA",
    authDomain: "examai-2024.firebaseapp.com",
    projectId: "examai-2024",
    storageBucket: "examai-2024.appspot.com",
    messagingSenderId: "752229224213",
    appId: "1:752229224213:web:b2cba258179e731ca0a31c",
    measurementId: "G-RVWYJE0Y0X",
  );

  try {
    await Firebase.initializeApp(
      options: firebaseConfig,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  setMetadata(); // Set metadata for the web
  runApp(MyApp());
}

void setMetadata() {
  // Set the title
  html.document.title = 'ExamAi';

  // Set the meta description
  var descriptionMeta = html.MetaElement()
    ..name = 'description'
    ..content =
        'ExamAi: AI-powered exam grading platform. Automate exam grading with the power of AI, a new way to grade coding, long answer questions, or even getting feedback on your physics homework.';
  html.document.head!.append(descriptionMeta);

  // Set the favicon
  var link = html.LinkElement()
    ..rel = 'icon'
    ..type = 'image/png'
    ..href = 'assets/images/appIcon.png';
  html.document.head!.append(link);

  // Set Open Graph meta tags
  var ogTitleMeta = html.MetaElement()
    ..setAttribute('property', 'og:title')
    ..content = 'ExamAi';
  html.document.head!.append(ogTitleMeta);

  var ogDescriptionMeta = html.MetaElement()
    ..setAttribute('property', 'og:description')
    ..content =
        'ExamAi: AI-powered exam grading platform. Automate exam grading with the power of AI, a new way to grade coding, long answer questions, or even getting feedback on your physics homework.';
  html.document.head!.append(ogDescriptionMeta);

  var ogImageMeta = html.MetaElement()
    ..setAttribute('property', 'og:image')
    ..content = 'assets/images/1200x630.png';
  html.document.head!.append(ogImageMeta);

  var ogUrlMeta = html.MetaElement()
    ..setAttribute('property', 'og:url')
    ..content = 'https://examai.ai';
  html.document.head!.append(ogUrlMeta);

  var ogTypeMeta = html.MetaElement()
    ..setAttribute('property', 'og:type')
    ..content = 'website';
  html.document.head!.append(ogTypeMeta);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // User is signed in, check role from Shared Preferences
          return FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (roleSnapshot.hasData) {
                if (roleSnapshot.data == 'Professor') {
                  return ProfessorScreen();
                } else {
                  return StudentScreen();
                }
              } else {
                // Default to SignInScreen if role is not found
                return SignInScreen();
              }
            },
          );
        } else {
          return SignInScreen();
        }
      },
    );
  }

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isSignUp = false;
  String statusMessage = "";
  bool _isPasswordVisible = false;
  List<bool> isSelected = [true, false];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await _saveUserRole();
      _navigateToDashboard();
    } catch (e) {
      setState(() {
        statusMessage = 'Sign-in error: $e';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser =
          await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      await _saveUserRole();
      _navigateToDashboard();
    } catch (e) {
      setState(() {
        statusMessage = 'Google Sign-In error: $e';
      });
    }
  }

  Future<void> _signUp() async {
    try {
      if (fullNameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        setState(() {
          statusMessage = 'Please fill all the fields.';
        });
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user?.updateProfile(
        displayName: fullNameController.text.trim(),
      );

      await _saveUserRole();
      setState(() {
        statusMessage = "Account created. Please sign in.";
        isSignUp = false;
      });

      _showAccountCreatedDialog();
    } catch (e) {
      setState(() {
        statusMessage = 'Sign-up error: $e';
      });
    }
  }

  Future<void> _saveUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = isSelected[0] ? 'Professor' : 'Student';
    await prefs.setString('userRole', role);
  }

  void _navigateToDashboard() {
    if (isSelected[0]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfessorScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentScreen()),
      );
    }
  }

  void _showAccountCreatedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Account created. Please sign in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
                left: 30.0,
                bottom: 30.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6938ef),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.school, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Exam AI",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                      const Text(
                        "Unlock Seamless Exam Creation \nand Intelligent Grading",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Automate exam grading with the power of Ai, a new way to grade coding, long answer questions, or even getting feedback on your physics homework. \n\nWe're giving back professors their precious time back!",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 60),
                      Flexible(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Image.asset(
                            'assets/images/login_image.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Right Side
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = constraints.maxWidth / 4;
                return Container(
                  padding: EdgeInsets.only(left: padding, right: padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome back! Please enter your details.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ToggleButtons(
                        isSelected: isSelected,
                        selectedColor: Colors.white,
                        fillColor: const Color(0xFF6938ef),
                        borderRadius: BorderRadius.circular(10),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Professor"),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Student"),
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              isSelected[buttonIndex] = buttonIndex == index;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (isSignUp)
                        TextField(
                          controller: fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  2)), // Set border radius to 2px
                              borderSide: BorderSide(
                                  color: Color(
                                      0xFFD2D5DC)), // Default border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  2)), // Set border radius to 2px
                              borderSide: BorderSide(
                                  color: Color(
                                      0xFFD2D5DC)), // Color when TextField is enabled
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  2)), // Set border radius to 2px
                              borderSide: BorderSide(
                                color: Color(
                                    0xFF6539EF), // Color when TextField is focused
                                width: 2.0, // Set border thickness to 3px
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email / ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(2)), // Set border radius to 2px
                            borderSide: BorderSide(
                                color:
                                    Color(0xFFD2D5DC)), // Default border color
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(2)), // Set border radius to 2px
                            borderSide: BorderSide(
                                color: Color(
                                    0xFFD2D5DC)), // Color when TextField is enabled
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(2)), // Set border radius to 2px
                            borderSide: BorderSide(
                              color: Color(0xFF6539EF),
                              width: 2.0, // Set border thickness to 3px
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(2)), // Set border radius to 2px
                            borderSide: BorderSide(
                                color:
                                    Color(0xFFD2D5DC)), // Default border color
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(2)), // Set border radius to 2px
                            borderSide: BorderSide(
                                color: Color(
                                    0xFFD2D5DC)), // Color when TextField is enabled
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(2)), // Set border radius to 2px
                            borderSide: BorderSide(
                              color: Color(0xFF6539EF),
                              width: 3.0, // Set border thickness to 3px
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (isSignUp) {
                            _signUp();
                          } else {
                            _signInWithEmailAndPassword();
                          }
                        },
                        child: Center(
                            child:
                                Text(isSignUp ? "Create Account" : "Sign in")),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6539EF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFD2D5DC),
                            width: 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SignInButton(
                            Buttons.Google,
                            text: "Sign in with Gmail",
                            onPressed: () {
                              _signInWithGoogle();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (statusMessage.isNotEmpty)
                        Text(
                          statusMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isSignUp
                              ? "Already have an account?"
                              : "Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSignUp = !isSignUp;
                                statusMessage = "";
                              });
                            },
                            child: Text(
                              isSignUp ? "Sign in" : "Sign up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6539EF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
