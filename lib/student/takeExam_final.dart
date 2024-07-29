import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../professor/colors_professor.dart';

class TakeExamFinal extends StatefulWidget {
  final String examId;
  final String colorToggle; // Add a color parameter

  TakeExamFinal({required this.examId, required this.colorToggle});

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
          backgroundColor: widget.colorToggle == "light"
              ? AppColorsLight.pure_white
              : AppColorsDark.pure_white,
          title: Text(
            'Submit Assessment?',
            style: TextStyle(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          content: Text(
            'Are you sure you want to submit your assessment? You will not be able to make any changes after submission.',
            style: TextStyle(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                    backgroundColor: widget.colorToggle == "light"
                        ? AppColorsLight.pure_white
                        : AppColorsDark.pure_white,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _saveStudentAnswers(context, exam, answers);
                    _showThankYouDialog(context, exam);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorToggle == "light"
                        ? AppColorsLight.main_purple
                        : AppColorsDark.main_purple,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.pure_white,
                    ),
                  ),
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
          backgroundColor: widget.colorToggle == "light"
              ? AppColorsLight.pure_white
              : AppColorsDark.pure_white,
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
                style: TextStyle(
                  fontSize: 16,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
              Text(
                '"${exam['course']} - ${exam['examName']}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.main_purple
                      : AppColorsDark.main_purple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Click 'Finish' to go back to your dashboard.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
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
                  foregroundColor: widget.colorToggle == "light"
                      ? AppColorsLight.pure_white
                      : AppColorsDark.pure_white,
                  backgroundColor: widget.colorToggle == "light"
                      ? AppColorsLight.main_purple
                      : AppColorsDark.main_purple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Finish',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.pure_white
                        : AppColorsDark.pure_white,
                  ),
                ),
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
            SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            SizedBox(width: 4),
            Icon(
              Icons.assignment,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
            ),
            SizedBox(width: 4),
            Text(
              'Assessment',
              style: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.main_purple
                      : AppColorsDark.main_purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Spacer(),
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
                color: widget.colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.pure_white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.light_grey
                        : AppColorsDark.light_grey,
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
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
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
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: widget.colorToggle == "light"
                                            ? AppColorsLight.black
                                            : AppColorsDark.black,
                                      ),
                                      textAlign: TextAlign
                                          .left, // Ensures text alignment
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2.0,
                                      right: 8,
                                    ), // Adjust this value as needed
                                    child: Text(
                                      '${question['weight']} pts',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: widget.colorToggle == "light"
                                            ? AppColorsLight.black
                                            : AppColorsDark.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: controllers[questionText],
                                maxLines: null,
                                style: TextStyle(
                                  color: widget.colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your answer here...',
                                  hintStyle: TextStyle(
                                    color: widget.colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.black,
                                  ),
                                  fillColor: widget.colorToggle == "light"
                                      ? AppColorsLight.light_grey
                                      : AppColorsDark.card_background,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: widget.colorToggle == "light"
                                          ? AppColorsLight.light_grey
                                          : AppColorsDark.light_grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: widget.colorToggle == "light"
                                          ? AppColorsLight.disabled_grey
                                          : AppColorsDark.light_grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: widget.colorToggle == "light"
                                          ? AppColorsLight.main_purple
                                          : AppColorsDark.main_purple,
                                      width:
                                          2.0, // Set border width to 3 pixels
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ), // Add 20 pixels box between questions
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
                        foregroundColor: widget.colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.pure_white,
                        backgroundColor: widget.colorToggle == "light"
                            ? AppColorsLight.main_purple
                            : AppColorsDark.main_purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.colorToggle == "light"
                              ? AppColorsLight.pure_white
                              : AppColorsDark.pure_white,
                        ),
                      ),
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
