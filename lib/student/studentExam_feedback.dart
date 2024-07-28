import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentExamFeedbackScreen extends StatelessWidget {
  final String examId;

  const StudentExamFeedbackScreen({Key? key, required this.examId})
      : super(key: key);

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
                    const Icon(Icons.analytics, color: Colors.black),
                    const SizedBox(width: 4),
                    const Text(
                      'Exam Analytics',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.black),
                    const SizedBox(width: 4),
                    const Icon(Icons.feedback, color: Color(0xFF6938EF)),
                    const SizedBox(width: 4),
                    const Text(
                      'Feedback',
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
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 1200,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Text('Exam Questions',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xfff2f4f7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${questions.length}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
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
                                  color: Color(0xfff9fafb),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        '${question['total_score'] ?? 0}/$possibleScore pts',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      children: [
                                        ListTile(
                                          title: Text(
                                            'Answer: ${question['answer'] ?? 'No answer provided'}',
                                            style: TextStyle(
                                                color: Colors.black87),
                                          ),
                                        ),
                                        if (question['feedback'] != null)
                                          Container(
                                            margin: const EdgeInsets.all(8.0),
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xfffbfaff),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Color(0xffd2d5da)),
                                            ),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Feedback from AI: ',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: question['feedback'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
