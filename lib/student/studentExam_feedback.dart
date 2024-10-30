import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../professor/colors_professor.dart';

class StudentExamFeedbackScreen extends StatelessWidget {
  final String examId;
  final String colorToggle;
  final VoidCallback onBack; // Add onBack callback

  const StudentExamFeedbackScreen({
    Key? key,
    required this.examId,
    required this.colorToggle,
    required this.onBack, // Include the onBack callback
  }) : super(key: key);

  Future<Map<String, dynamic>> fetchExamDetails(String examId) async {
    final examSnapshot =
        await FirebaseFirestore.instance.collection('Exams').doc(examId).get();

    if (examSnapshot.exists) {
      return examSnapshot.data()!;
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>?> fetchStudentGrades(
      String examId, String email) async {
    final gradesSnapshot = await FirebaseFirestore.instance
        .collection('Exams')
        .doc(examId)
        .collection('graded')
        .doc(email)
        .get();

    if (gradesSnapshot.exists) {
      return gradesSnapshot.data();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchExamDetails(examId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading exam details'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No exam details found'));
        }

        final examDetails = snapshot.data!;
        final List<dynamic> examQuestions = examDetails['questions'] ?? [];

        print('Questions field in Exams > $examId: $examQuestions');

        return FutureBuilder<Map<String, dynamic>?>(
          future: fetchStudentGrades(
              examId, FirebaseAuth.instance.currentUser!.email!),
          builder: (context, gradesSnapshot) {
            if (gradesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (gradesSnapshot.hasError) {
              return Center(child: Text('Error loading grades'));
            } else if (!gradesSnapshot.hasData || gradesSnapshot.data == null) {
              return Center(child: Text('No grades found'));
            }

            final studentGrades = gradesSnapshot.data!;
            final List<dynamic> questions = studentGrades['grades'] ?? [];

            return Scaffold(
              backgroundColor: colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark.pure_white,
              appBar: AppBar(
                backgroundColor: colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.pure_white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: onBack, // Call onBack callback when pressed
                ),
                title: Row(
                  children: [
                    Icon(Icons.home,
                        color: colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black),
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
                      Icons.analytics,
                      color: colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Exam Analytics',
                      style: TextStyle(
                        color: colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.feedback,
                        color: colorToggle == "light"
                            ? AppColorsLight.main_purple
                            : AppColorsDark.main_purple),
                    const SizedBox(width: 4),
                    Text(
                      'Feedback',
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
                          ? Icon(Icons.person,
                              color: colorToggle == "light"
                                  ? AppColorsLight.main_purple
                                  : AppColorsDark.main_purple)
                          : null,
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 1200,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                    decoration: BoxDecoration(
                      color: colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.pure_white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colorToggle == "light"
                              ? AppColorsLight.light_grey
                              : AppColorsDark.light_grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Text(
                              'Exam Questions',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.black,
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorToggle == "light"
                                    ? AppColorsLight.main_purple
                                    : AppColorsDark.main_purple,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${questions.length}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: colorToggle == "light"
                                        ? AppColorsLight.pure_white
                                        : AppColorsDark.pure_white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Questions list
                        Expanded(
                          child: ListView.builder(
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final question = questions[index];
                              final possibleQuestion = examQuestions.firstWhere(
                                  (q) =>
                                      q['question'] == question['question_id'],
                                  orElse: () => {});
                              final possibleScore = (possibleQuestion['rubrics']
                                          as List<dynamic>?)
                                      ?.map(
                                          (rubric) => rubric['weight'] as int?)
                                      .reduce((a, b) => (a ?? 0) + (b ?? 0)) ??
                                  20;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  elevation: 0, // Remove shadow
                                  color: colorToggle == "light"
                                      ? AppColorsLight.lightest_grey
                                      : AppColorsDark.card_background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: colorToggle == "light"
                                          ? AppColorsLight.light_grey
                                          : AppColorsDark.light_grey,
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      title: Text(
                                        'Q${index + 1}. ${question['question_id']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorToggle == "light"
                                              ? AppColorsLight.black
                                              : AppColorsDark.black,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${question['total_score'] ?? 0}/$possibleScore pts',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorToggle == "light"
                                              ? AppColorsLight.black
                                              : AppColorsDark.black,
                                        ),
                                      ),
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(8.0),
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: colorToggle == "light"
                                                ? AppColorsLight.lightest_grey
                                                : AppColorsDark
                                                    .card_light_background,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: colorToggle == "light"
                                                  ? AppColorsLight.light_grey
                                                  : AppColorsDark.light_grey,
                                            ),
                                          ),
                                          child: ListTile(
                                            title: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Answer:\n\n',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorToggle ==
                                                              "light"
                                                          ? AppColorsLight.black
                                                          : AppColorsDark.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: question['answer'] ??
                                                        'No answer provided',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: colorToggle ==
                                                              "light"
                                                          ? AppColorsLight.black
                                                          : AppColorsDark.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (question['feedback'] != null)
                                          Container(
                                            margin: const EdgeInsets.all(8.0),
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                colors: [
                                                  Color.fromARGB(
                                                      160, 0, 255, 234), // Gold
                                                  Color.fromARGB(100, 187, 0,
                                                      160), // Silver
                                                  Color.fromARGB(160, 255, 106,
                                                      0), // Bronze
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: colorToggle == "light"
                                                    ? AppColorsLight.light_grey
                                                    : AppColorsDark.light_grey,
                                              ),
                                            ),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Feedback from AI: ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorToggle ==
                                                              "light"
                                                          ? AppColorsLight.black
                                                          : AppColorsDark.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: question['feedback'],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: colorToggle ==
                                                              "light"
                                                          ? AppColorsLight.black
                                                          : AppColorsDark.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
