import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TakeExamFinal extends StatefulWidget {
  final String examId;

  TakeExamFinal({required this.examId});

  @override
  _TakeExamFinalState createState() => _TakeExamFinalState();
}

class _TakeExamFinalState extends State<TakeExamFinal> {
  Map<String, TextEditingController> controllers = {};

  Future<Map<String, dynamic>> _fetchExamDetails() async {
    DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
        .collection('Exams')
        .doc(widget.examId)
        .get();
    return examSnapshot.data() as Map<String, dynamic>;
  }

  void _showSubmissionConfirmationDialog(BuildContext context,
      Map<String, dynamic> exam, Map<String, String> answers) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Submit Assessment?'),
          content: Text(
              'Are you sure you want to submit your assessment? You will not be able to make any changes after submission.'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _saveStudentAnswers(context, exam, answers);
                    _showThankYouDialog(context, exam);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6938EF),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveStudentAnswers(BuildContext context,
      Map<String, dynamic> exam, Map<String, String> answers) async {
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? 'anonymous';
    DocumentReference studentRef =
        FirebaseFirestore.instance.collection('Students').doc(userEmail);

    DocumentSnapshot studentSnapshot = await studentRef.get();
    if (!studentSnapshot.exists) {
      await studentRef.set({'completedExams': {}});
    }

    await studentRef.update({
      'completedExams.${widget.examId}': {
        'examName': exam['examName'],
        'course': exam['course'],
        'answers': answers,
      }
    });
  }

  void _showThankYouDialog(BuildContext context, Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thank you for taking the test for the',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '"${exam['course']} - ${exam['examName']}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6938EF)),
              ),
              SizedBox(height: 10),
              Text(
                "Please choose 'Finish' to go back to your dashboard.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext)
                      .popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF6938EF),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Finish'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controllers.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
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
                        String questionText = question['question'];
                        if (!controllers.containsKey(questionText)) {
                          controllers[questionText] = TextEditingController();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Question ${index + 1}: $questionText',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2, // Adjust line spacing
                                      ),
                                      textAlign: TextAlign
                                          .left, // Ensures text alignment
                                      strutStyle: const StrutStyle(
                                        height: 1.2, // Adjust the height
                                        forceStrutHeight:
                                            true, // Forces the height to be applied
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 2.0,
                                        right:
                                            8), // Adjust this value as needed
                                    child: Text(
                                      '${question['weight']} pts',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: controllers[questionText],
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your answer here...',
                                  fillColor: Color(0xFFF2F4F7),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFD1D6DC),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFD1D6DC),
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
                              const SizedBox(
                                  height:
                                      20), // Add 20 pixels box between questions
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
                        Map<String, String> answers = {};
                        controllers.forEach((key, value) {
                          answers[key] = value.text;
                        });
                        _showSubmissionConfirmationDialog(
                            context, exam, answers); // Pass the exam data here
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
