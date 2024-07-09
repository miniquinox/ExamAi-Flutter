import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'takeExam_final.dart';

class IntroductionPage extends StatelessWidget {
  final String examId;

  IntroductionPage({required this.examId});

  Future<Map<String, dynamic>> _fetchExamDetails() async {
    DocumentSnapshot examSnapshot =
        await FirebaseFirestore.instance.collection('Exams').doc(examId).get();
    return examSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
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
            const Icon(Icons.assignment, color: Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(width: 4),
            const Text(
              'Exams',
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black),
            const SizedBox(width: 4),
            const Icon(Icons.assignment, color: Color(0xFF6938EF)),
            const SizedBox(width: 4),
            const Text(
              'Instructions',
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchExamDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var exam = snapshot.data!;
          String about =
              'ExamAi grades your submissions instantly by matching your answers with professor-defined rubrics. Our AI ensures accurate and fair grading for all types of responses, whether they are code, short texts, or detailed explanations. You get instant feedback to understand your performance right away.';

          String instructions =
              'ExamAI can understand and grade various response formats like code, multiple-choice, short answers, and long texts. Write your answers in any format, and ExamAi will interpret them accurately. Ensure your responses are clear and well-organized. For code, use proper formatting. For multiple-choice, select the correct option. ExamAi has you covered no matter how you respond!';

          String timeCap = exam['timeCap'] ?? 'Placeholder time';

          return Container(
            margin: const EdgeInsets.only(top: 80, left: 200, right: 200),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Color(0xFFEEEEEE),
                  width: 1), // Added outline with #EEEEEE color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Adjusts the box size based on content
              children: [
                const Text(
                  'Introduction',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'About',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  about,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(instructions, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                const Text(
                  'Time',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  timeCap,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakeExamFinal(examId: examId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF6938EF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Start'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
