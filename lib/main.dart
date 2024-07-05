import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'professor/professor_dashboard.dart';
import 'student/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase options for web
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  List<bool> isSelected = [
    true,
    false
  ]; // Initial state with 'Professor' selected

  @override
  void dispose() {
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
      // Redirect based on the selected role
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
    } catch (e) {
      print('Sign-in error: $e');
      // Handle sign-in errors here
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final googleUser =
          await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());

      // Get the selected role
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
    } catch (e) {
      print('Google Sign-In error: $e');
      // Handle Google Sign-In errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side
          Expanded(
            child: Container(
              color: Colors.purple[600],
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Exam AI",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Unlock Seamless Exam Creation and Intelligent Grading",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lectus viverra non fringilla lobortis dignissim lorem enim.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/images/login_image.png',
                        height: 300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right Side
          Expanded(
            child: Container(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome back! Please enter your details.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 30),
                  ToggleButtons(
                    isSelected: isSelected,
                    selectedColor: Colors.white,
                    fillColor: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Professor"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email / ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                    obscureText: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(value: false, onChanged: (bool? value) {}),
                          Text("Remember for 30 days"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("Forgot password"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _signInWithEmailAndPassword();
                    },
                    child: Container(
                      width: double.infinity,
                      child: Center(child: Text("Sign in")),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  SignInButton(
                    Buttons.Google,
                    text: "Sign in with Gmail",
                    onPressed: () {
                      _signInWithGoogle();
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don’t have an account?"),
                      TextButton(
                        onPressed: () {},
                        child: Text("Sign up"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
