import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examai_flutter/professor/professor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CreateExamReview extends StatelessWidget {
  final String examName;
  final String course;
  final String date;
  final String time;
  final List<String> students;
  final List<Map<String, dynamic>> questions;
  final String? examId; // Add examId parameter

  const CreateExamReview({
    super.key,
    required this.examName,
    required this.course,
    required this.date,
    required this.time,
    required this.students,
    required this.questions,
    this.examId, // Initialize examId
  });

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
              'Create new exam',
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
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: _buildProgressColumn(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 100.0),
              child: _buildFormColumn(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressColumn() {
    return Container(
      width: 225,
      padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildStepper(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep(
          title: 'Exam Details',
          subtitle: 'Enter basic information',
          isActive: false,
          isCompleted: true,
        ),
        _buildStep(
          title: 'Add Questions',
          subtitle: 'Create and edit questions',
          isActive: false,
          isCompleted: true,
        ),
        _buildStep(
          title: 'Review',
          subtitle: 'Check and review the exam',
          isActive: true,
          isCompleted: false,
        )
      ],
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isActive
                    ? const Color(0xFF6938EF)
                    : isCompleted
                        ? Colors.green
                        : Colors.grey,
                child: Icon(
                  isActive
                      ? MdiIcons.checkCircle
                      : MdiIcons.checkboxBlankCircle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Container(
                height: 40,
                width: 2,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF6938EF) : Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? const Color(0xFF6938EF) : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormColumn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text('Review',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildExamDetails(),
                          const SizedBox(height: 16),
                          _buildAddQuestions(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showPublishDialog(context);
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
                          child: const Text('Publish'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: const Text('Publish Exam?'),
          content: const Text(
              'Please, confirm publishing. Students will be able to take and can participate in this exam.'),
          actions: [
            // Removed the "Don't show again" Checkbox and Text
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the end
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // Reduced horizontal padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16), // Increased space
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext loadingContext) {
                        _publishExam(context, loadingContext);
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6938EF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // Reduced horizontal padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Confirm Publish',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _publishExam(
      BuildContext parentContext, BuildContext loadingContext) async {
    try {
      final examData = {
        'examName': examName,
        'course': course,
        'date': date,
        'time': time,
        'students': students,
        'questions': questions,
      };

      DocumentReference examRef;

      if (examId != null) {
        examRef = FirebaseFirestore.instance.collection('Exams').doc(examId);
        await examRef.update(examData);
      } else {
        examRef =
            await FirebaseFirestore.instance.collection('Exams').add(examData);
      }

      String? professorEmail = FirebaseAuth.instance.currentUser?.email;
      if (professorEmail == null) {
        throw Exception("Professor email is null");
      }

      DocumentReference professorRef = FirebaseFirestore.instance
          .collection('Professors')
          .doc(professorEmail);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(professorRef);

        if (!snapshot.exists) {
          transaction.set(professorRef, {
            'currentExams': [examRef.id]
          });
        } else {
          List<dynamic> currentExams = snapshot.get('currentExams') ?? [];
          if (!currentExams.contains(examRef.id)) {
            currentExams.add(examRef.id);
          }
          transaction.update(professorRef, {'currentExams': currentExams});
        }
      });

      // Update each student's current exams
      for (String studentEmail in students) {
        DocumentReference studentRef =
            FirebaseFirestore.instance.collection('Students').doc(studentEmail);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(studentRef);

          if (!snapshot.exists) {
            transaction.set(studentRef, {
              'currentExams': [examRef.id]
            });
          } else {
            List<dynamic> currentExams = snapshot.get('currentExams') ?? [];
            if (!currentExams.contains(examRef.id)) {
              currentExams.add(examRef.id);
            }
            transaction.update(studentRef, {'currentExams': currentExams});
          }
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(loadingContext).pop(); // Close the loading dialog
        _showSuccessDialog(parentContext);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(loadingContext).pop(); // Close the loading dialog
        showDialog(
          context: parentContext,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to publish exam. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      });
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(40), // Added padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MdiIcons
                    .checkCircleOutline, // Updated to use an icon from the material_design_icons_flutter package
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Exam ',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextSpan(
                        text: '"$examName"',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: '\nSuccessfully created!',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  textAlign:
                      TextAlign.center, // This applies to the Text widget
                ),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).popUntil((route) => route.isFirst);
                Navigator.of(dialogContext).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ProfessorScreen()));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF6938EF),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Set corner radius to 9
                ),
              ),
              child: const Text('Back to home'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExamDetails() {
    return ExpansionTile(
      title: const Text('Exam Details',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      children: [
        ListTile(
          title: const Text('Exam name'),
          subtitle: TextField(
            controller: TextEditingController(text: examName),
            decoration: InputDecoration(
              fillColor: const Color(0xfff2f4f7),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            enabled: false, // Lock the input box
          ),
        ),
        ListTile(
          title: const Text('Course'),
          subtitle: TextField(
            controller: TextEditingController(text: course),
            decoration: InputDecoration(
              fillColor: const Color(0xfff2f4f7),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            enabled: false, // Lock the input box
          ),
        ),
        ListTile(
          title: const Text('Date & time'),
          subtitle: TextField(
            controller: TextEditingController(text: '$date at $time'),
            decoration: InputDecoration(
              fillColor: const Color(0xfff2f4f7),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            enabled: false, // Lock the input box
          ),
        ),
        ListTile(
          title: const Text('Students'),
          subtitle: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xfff2f4f7),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: students
                  .map((student) => Chip(
                        label: Text(student),
                        backgroundColor: Colors.white,
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddQuestions() {
    return ExpansionTile(
      title: const Text(
        'Add Questions',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      children: questions.map((question) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xfffcfcfd),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xffcbcfd7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${questions.indexOf(question) + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${question['weight']} pts',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f1f5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    question['question'],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                ...question['rubrics'].map<Widget>((rubric) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f1f5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rubric['rubric'],
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            '${rubric['weight']} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

void main() => runApp(const MaterialApp(
      home: CreateExamReview(
        examName: 'Mathematics 101',
        course: 'Math',
        date: 'July 24 - Aug 24, 2024',
        time: '08:00 PM',
        students: ['Umar', 'Asif'],
        questions: [
          {
            'question':
                'Explain the concept of Object-Oriented Programming (OOP).',
            'weight': 20,
            'rubrics': [
              {
                'rubric':
                    'Correct implementation of the prime checking algorithm.',
                'weight': 10
              },
              {
                'rubric': 'Proper use of functions and coding standards',
                'weight': 10
              },
            ]
          },
          {
            'question':
                'Write a Python function that checks if a given number is a prime number.',
            'weight': 20,
            'rubrics': [
              {
                'rubric':
                    'Correct implementation of the prime checking algorithm.',
                'weight': 10
              },
              {
                'rubric': 'Proper use of functions and coding standards',
                'weight': 10
              },
            ]
          }
        ],
      ),
    ));
