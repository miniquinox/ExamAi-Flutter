import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TakeExamFinal extends StatelessWidget {
  final String examId;

  TakeExamFinal({required this.examId});

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
            const Icon(Icons.assignment, color: Color(0xFF6938EF)),
            const SizedBox(width: 4),
            const Text(
              'Assessment',
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
          var questions = exam['questions'] ?? [];
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 160,
              height: MediaQuery.of(context).size.height - 160,
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 1), // Updated outline to #EEEEEE
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${exam['course']} - ${exam['examName']}',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        var question = questions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${index + 1}: ${question['question']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2, // Adjust line spacing
                                ),
                                textAlign: TextAlign
                                    .left, // Optional: Ensures text alignment
                                strutStyle: const StrutStyle(
                                  height: 1.2, // Adjust the height
                                  forceStrutHeight:
                                      true, // Forces the height to be applied
                                ),
                              ),
                              const SizedBox(height: 10),
                              const TextField(
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: 'Enter your answer here...',
                                  fillColor: Color(0xFFFFFFFF),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFD0D5DD),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFD0D5DD),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF6938EF),
                                      width:
                                          2.0, // Set border width to 3 pixels
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle submission and navigate to the next question or finish the exam
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
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TakeExamFinal(examId: 'sampleExamId'),
  ));
}
