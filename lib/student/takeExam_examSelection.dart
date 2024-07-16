import 'package:examai_flutter/student/takeExam_instructions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class StudentPortalScreen extends StatefulWidget {
  const StudentPortalScreen({Key? key}) : super(key: key);

  @override
  _StudentPortalScreenState createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  User? user;
  List<Map<String, dynamic>> exams = [];

  @override
  void initState() {
    super.initState();
    _firebaseService.authStateChanges.listen((user) {
      if (user != null) {
        setState(() {
          this.user = user;
        });
        fetchUserAndExams(user.email!);
      } else {
        print('No user is currently signed in.');
      }
    });
  }

  Future<void> fetchUserAndExams(String email) async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcfcfe),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.home, color: Colors.black),
            const SizedBox(width: 4),
            const Text(
              'Home',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black),
            const SizedBox(width: 4),
            const Icon(Icons.assignment, color: Color(0xFF6938EF)),
            const SizedBox(width: 4),
            const Text(
              'Exams',
              style: TextStyle(
                  color: Color(0xFF6938EF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? ''),
              backgroundColor: Colors.transparent,
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? const Icon(Icons.person, color: Colors.white)
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
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam['course'] ?? 'Placeholder',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(exam['examName'] ?? 'Placeholder',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Professor',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          exam['professorURL'] != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(exam['professorURL']),
                                  radius: 24)
                              : const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 24,
                                  child:
                                      Icon(Icons.person, color: Colors.white)),
                          const SizedBox(width: 10),
                          Text(
                            exam['professorName'] != null &&
                                    exam['professorName'].length > 18
                                ? '${exam['professorName'].substring(0, 18)}...'
                                : exam['professorName'] ??
                                    'Joaquin Carretero...',
                            style: const TextStyle(fontSize: 16),
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
                        const Text('Students',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Date and Time",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 5),
                  Text(exam['date'] ?? 'Placeholder'),
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 5),
                  Text(exam['time'] ?? 'Placeholder'),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Descriptions',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(exam['description'] ?? 'Placeholder',
                  style: const TextStyle(color: Colors.grey)),
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
                          builder: (context) =>
                              IntroductionPage(examId: exam['id']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF6938EF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: const Text('Start'),
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

void main() => runApp(const MaterialApp(home: StudentPortalScreen()));
