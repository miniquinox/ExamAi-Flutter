import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../professor/colors_professor.dart';
import 'takeExam_final.dart';

class IntroductionPage extends StatelessWidget {
  final String examId;
  final String colorToggle; // Add a color parameter

  IntroductionPage({required this.examId, required this.colorToggle});

  Future<Map<String, dynamic>> _fetchExamDetails() async {
    DocumentSnapshot examSnapshot =
        await FirebaseFirestore.instance.collection('Exams').doc(examId).get();
    return examSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorToggle == "light"
          ? AppColorsLight.lightest_grey
          : AppColorsDark.pure_white,
      appBar: AppBar(
        backgroundColor: colorToggle == "light"
            ? AppColorsLight.lightest_grey
            : AppColorsDark.pure_white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorToggle == "light"
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
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            const SizedBox(width: 4),
            Text(
              'Home',
              style: TextStyle(
                  color: colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.assignment,
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            const SizedBox(width: 4),
            Text(
              'Exams',
              style: TextStyle(
                  color: colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.assignment,
              color: colorToggle == "light"
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
            ),
            const SizedBox(width: 4),
            Text(
              'Instructions',
              style: TextStyle(
                  color: colorToggle == "light"
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
                      color: colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                    )
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

          String timeCap = exam['timeCap'] ?? 'Feature Not Yet Available';

          return Container(
            margin: const EdgeInsets.only(top: 80, left: 200, right: 200),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark.card_background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colorToggle == "light"
                      ? AppColorsLight.light_grey
                      : AppColorsDark.light_grey,
                  width: 1), // Added outline with #EEEEEE color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Adjusts the box size based on content
              children: [
                Text(
                  'Introduction',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  about,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.disabled_grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  instructions,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.disabled_grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  timeCap,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.disabled_grey,
                  ),
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakeExamFinal(
                            examId: examId,
                            colorToggle: colorToggle,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.pure_white,
                      backgroundColor: colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.pure_white,
                      ),
                    ),
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
