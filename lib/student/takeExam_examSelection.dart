import 'package:examai_flutter/student/takeExam_instructions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../professor/colors_professor.dart';
import 'firebase_service.dart';

class StudentPortalScreen extends StatefulWidget {
  final String colorToggle; // Add a color parameter

  const StudentPortalScreen({Key? key, required this.colorToggle})
      : super(key: key);

  @override
  _StudentPortalScreenState createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  User? user;
  List<Map<String, dynamic>> exams = [];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _firebaseService.authStateChanges.listen((user) {
      if (user != null) {
        setState(() {
          this.user = user;
        });
        if (!_isFetching) {
          fetchUserAndExams(user.email!);
        }
      } else {
        print('No user is currently signed in.');
      }
    });
  }

  Future<void> fetchUserAndExams(String email) async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
    });

    print('Fetching exams for user: $email');
    try {
      // Ensure email is trimmed and lowercased
      email = email.trim().toLowerCase();
      print('Normalized email: $email');

      // Check if the user is authenticated
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.email != email) {
        print('User is not authenticated or email does not match.');
        return;
      }

      // Clear the exams list before fetching new data
      setState(() {
        exams.clear();
      });

      final userData = await _firebaseService.getUserData(email);
      if (userData != null) {
        final currentExams = List<String>.from(userData['currentExams'] ?? []);
        print('Current exams: $currentExams');

        for (String examId in currentExams) {
          final examDoc = await FirebaseFirestore.instance
              .collection('Exams')
              .doc(examId)
              .get();

          if (examDoc.exists) {
            print('Exam document exists for ID: $examId');
            setState(() {
              exams.add({
                'id': examDoc.id,
                ...examDoc.data()!,
              });
            });
          } else {
            print('Exam document does not exist for ID: $examId');
          }
        }
      } else {
        print('No user data found for email: $email');
      }
    } catch (e) {
      print('Error fetching user or exams: $e');
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colorToggle == "light"
          ? AppColorsLight.lightest_grey
          : AppColorsDark.pure_white,
      appBar: AppBar(
        backgroundColor: widget.colorToggle == "light"
            ? AppColorsLight.lightest_grey
            : AppColorsDark.pure_white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: widget.colorToggle == "light"
                ? AppColorsLight.black
                : AppColorsDark.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Icon(
              Icons.home,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            const SizedBox(width: 4),
            Text(
              'Home',
              style: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.assignment,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
            ),
            const SizedBox(width: 4),
            Text(
              'Exams',
              style: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.main_purple
                      : AppColorsDark.main_purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? ''),
              backgroundColor: Colors.transparent,
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? Icon(
                      Icons.person,
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                    )
                  : null,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: exams.map((exam) => buildExamCard(exam)).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildExamCard(Map<String, dynamic> exam) {
    return SizedBox(
      width: 500,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        color: widget.colorToggle == "light"
            ? AppColorsLight.pure_white
            : AppColorsDark.card_background,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.light_grey
                  : AppColorsDark.light_grey,
              width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam['course'] ?? 'Placeholder',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                exam['examName'] ?? 'Placeholder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Professor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          exam['professorURL'] != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(exam['professorURL']),
                                  radius: 24,
                                )
                              : CircleAvatar(
                                  backgroundColor: widget.colorToggle == "light"
                                      ? AppColorsLight.main_purple_light
                                      : AppColorsDark.main_purple_light,
                                  radius: 24,
                                  child: Icon(
                                    Icons.person,
                                    color: widget.colorToggle == "light"
                                        ? AppColorsLight.main_purple_dark
                                        : AppColorsDark.main_purple_dark,
                                  ),
                                ),
                          const SizedBox(width: 10),
                          Text(
                            exam['professorName'] != null &&
                                    exam['professorName'].length > 18
                                ? '${exam['professorName'].substring(0, 18)}...'
                                : exam['professorName'] ?? 'Unknown...',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Students',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.colorToggle == "light"
                                ? AppColorsLight.black
                                : AppColorsDark.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          children: [
                            ...List.generate(
                              (exam['students']?.length ?? 0) > 4
                                  ? 4
                                  : exam['students']?.length ?? 0,
                              (index) => CircleAvatar(
                                backgroundColor: [
                                  Colors.red,
                                  Colors.green,
                                  Colors.blue,
                                  Colors.purple
                                ][index % 4],
                                radius: 12,
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                            if ((exam['students']?.length ?? 0) > 4)
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 12,
                                child: Text(
                                  '+${(exam['students']?.length ?? 0) - 4}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.black,
                                  ),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "Date and Time",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    exam['date'] ?? 'Placeholder',
                    style: TextStyle(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    exam['time'] ?? 'Placeholder',
                    style: TextStyle(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Descriptions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                exam['description'] ?? 'Feature Not Supported yet',
                style: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.disabled_grey
                      : AppColorsDark.disabled_grey,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IntroductionPage(
                            examId: exam['id'],
                            colorToggle: widget.colorToggle,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: widget.colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.pure_white,
                      backgroundColor: widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.pure_white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
