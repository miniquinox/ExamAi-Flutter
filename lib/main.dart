import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'professor/professor_dashboard.dart';
import 'student/student_dashboard.dart';

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
              ), // Add padding around the container except on the right side
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6938ef), // Background color
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                      32.0), // Padding inside the container
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Align items to the start of the column
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment:
                            Alignment.topLeft, // Align text to the top left
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Use minimum space
                          children: const [
                            Icon(Icons.school,
                                color: Colors.white), // Add the icon
                            SizedBox(width: 8), // Space between icon and text
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
                      // Spacer(), // Fill the empty space
                      SizedBox(height: 60), // Add some space (20 pixels
                      Flexible(
                        child: Align(
                          alignment: Alignment
                              .bottomRight, // Position at the bottom right
                          child: Image.asset(
                            'assets/images/login_image.png',
                            fit: BoxFit
                                .contain, // Scales the image to fit within the space without cutting or distorting
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
                              color: Color(
                                  0xFF6539EF), // Color when TextField is focused
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
                              color: Color(
                                  0xFF6539EF), // Color when TextField is focused
                              width: 3.0, // Set border thickness to 3px
                            ),
                          ),
                          suffixIcon: Icon(Icons.visibility),
                        ),
                        obscureText: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                  value: false, onChanged: (bool? value) {}),
                              const Text("Remember for 30 days"),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("Forgot password"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _signInWithEmailAndPassword();
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Center(child: Text("Sign in")),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF6539EF), // Set the background color
                          foregroundColor:
                              Colors.white, // Set the foreground color to white
                          padding: const EdgeInsets.symmetric(
                              vertical: 18), // Make the button a bit taller
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Less rounded edges
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              8), // Set the corner radius here
                          border: Border.all(
                            color: Color(0xFFD2D5DC), // Border color
                            width: 1.0, // Border width
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8), // Apply the same borderRadius to ClipRRect
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     const Text("Don’t have an account?"),
                      //     TextButton(
                      //       onPressed: () {},
                      //       child: const Text("Sign up"),
                      //     ),
                      //   ],
                      // ),
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
