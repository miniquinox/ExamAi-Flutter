import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:examai_flutter/professor/professor_dashboard.dart';
import 'package:go_router/go_router.dart';
import 'colors_professor.dart';

class CreateExamReview extends StatelessWidget {
  final String examName;
  final String course;
  final String date;
  final String time;
  final List<String> students;
  final List<Map<String, dynamic>> questions;
  final String? examId; // Add examId parameter
  final String colorToggle; // Add a color parameter

  const CreateExamReview(
      {super.key,
      required this.examName,
      required this.course,
      required this.date,
      required this.time,
      required this.students,
      required this.questions,
      this.examId, // Initialize examId
      required this.colorToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorToggle == "light"
          ? AppColorsLight.lightest_grey
          : AppColorsDark.pure_white,
      appBar: AppBar(
        backgroundColor: colorToggle == "light"
            ? AppColorsLight.light_grey
            : AppColorsDark.light_grey,
        elevation: 0,
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
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
            ),
            const SizedBox(width: 4),
            Text(
              'Create new exam',
              style: TextStyle(
                color: colorToggle == "light"
                    ? AppColorsLight.main_purple
                    : AppColorsDark.main_purple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
                          ? AppColorsLight.pure_white
                          : AppColorsDark.pure_white,
                    )
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
          Text(
            'Steps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
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
                    ? colorToggle == "light"
                        ? AppColorsLight.main_purple
                        : AppColorsDark.main_purple
                    : isCompleted
                        ? Colors.green
                        : colorToggle == "light"
                            ? AppColorsLight.disabled_grey
                            : AppColorsDark.disabled_grey,
                child: Icon(
                  isActive ? Icons.check_circle : Icons.circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Container(
                height: 40,
                width: 2,
                color: isCompleted
                    ? Colors.green
                    : colorToggle == "light"
                        ? AppColorsLight.disabled_grey
                        : AppColorsDark.disabled_grey,
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
                  color: isActive
                      ? colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple
                      : colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive
                      ? colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple
                      : colorToggle == "light"
                          ? AppColorsLight.disabled_grey
                          : AppColorsDark.disabled_grey,
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
                color: colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.pure_white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: colorToggle == "light"
                      ? AppColorsLight.light_grey
                      : AppColorsDark.light_grey,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
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
                            foregroundColor: colorToggle == "light"
                                ? AppColorsLight.black
                                : AppColorsDark.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.pure_white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: colorToggle == "light"
                                  ? AppColorsLight.pure_white
                                  : AppColorsDark.pure_white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showPublishDialog(context);
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
                            'Publish',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorToggle == "light"
                                  ? AppColorsLight.pure_white
                                  : AppColorsDark.pure_white,
                            ),
                          ),
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
          backgroundColor: colorToggle == "light"
              ? AppColorsLight.pure_white
              : AppColorsDark.pure_white, // Set background color to white
          title: Text(
            'Publish Exam?',
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          content: Text(
            'Please, confirm publishing. Students will be able to take and can participate in this exam.',
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
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
                    foregroundColor: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                    backgroundColor: colorToggle == "light"
                        ? AppColorsLight.pure_white
                        : AppColorsDark.pure_white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // Reduced horizontal padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
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
                    backgroundColor: colorToggle == "light"
                        ? AppColorsLight.main_purple
                        : AppColorsDark.main_purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // Reduced horizontal padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm Publish',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorToggle == "light"
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

  bool _validateExamData(BuildContext context) {
    print("Validating exam data...");

    if (examName.isEmpty) {
      print("Validation Error: Exam name is empty.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, "Exam name cannot be empty.");
      });
      return false;
    }

    if (questions.isEmpty) {
      print("Validation Error: No questions added.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, "Please add at least one question.");
      });
      return false;
    }

    if (students.isEmpty || students.contains('')) {
      print("Validation Error: No students added or empty email.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(
            context, "Please ensure all students have valid email addresses.");
      });
      return false;
    }

    print("All validation checks passed.");
    return true;
  }

  Future<void> _publishExam(
      BuildContext parentContext, BuildContext loadingContext) async {
    print("Running validation...");

    // Step 1: Run validation before performing Firebase operations
    if (!_validateExamData(parentContext)) {
      print("Validation failed, stopping operation.");
      // Close the loading dialog if validation fails
      Navigator.of(loadingContext).pop(); // Close the loading dialog
      return; // Exit early to ensure Firebase operations don't happen
    }

    print("Validation passed, proceeding with Firebase operations...");

    try {
      final String? professorName =
          FirebaseAuth.instance.currentUser?.displayName;
      final String? professorEmail = FirebaseAuth.instance.currentUser?.email;

      if (professorEmail == null) {
        throw Exception("Professor email is null");
      }

      print("Professor name: $professorName, email: $professorEmail");

      final examData = {
        'examName': examName,
        'course': course,
        'date': date,
        'time': time,
        'students': students.where((student) => student.isNotEmpty).toList(),
        'questions': questions,
        'professorName': professorName,
      };

      DocumentReference examRef;

      // Step 2: Create or update the exam in Firestore
      if (examId != null) {
        print("Updating existing exam with ID: $examId");
        examRef = FirebaseFirestore.instance.collection('Exams').doc(examId);
        await examRef.update(examData); // Update existing exam
        print("Exam updated.");
      } else {
        print("Creating new exam...");
        examRef =
            await FirebaseFirestore.instance.collection('Exams').add(examData);
        print("New exam created with ID: ${examRef.id}");
      }

      // Step 3: Update professor's current exams
      print("Updating professor's current exams...");
      DocumentReference professorRef = FirebaseFirestore.instance
          .collection('Professors')
          .doc(professorEmail);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(professorRef);

        if (!snapshot.exists) {
          print("Professor document doesn't exist, creating new...");
          transaction.set(professorRef, {
            'currentExams': [examRef.id],
          });
        } else {
          print("Updating existing professor document...");
          List<dynamic> currentExams = snapshot.get('currentExams') ?? [];
          if (!currentExams.contains(examRef.id)) {
            currentExams.add(examRef.id);
          }
          transaction.update(professorRef, {'currentExams': currentExams});
        }
      });

      // Step 4: Update each student's current exams (skipping empty strings)
      for (String studentEmail
          in students.where((student) => student.isNotEmpty)) {
        print("Updating student: $studentEmail");
        DocumentReference studentRef =
            FirebaseFirestore.instance.collection('Students').doc(studentEmail);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(studentRef);

          if (!snapshot.exists) {
            print("Student document doesn't exist, creating new...");
            transaction.set(studentRef, {
              'currentExams': [examRef.id],
            });
          } else {
            print("Updating existing student document...");
            List<dynamic> currentExams = snapshot.get('currentExams') ?? [];
            if (!currentExams.contains(examRef.id)) {
              currentExams.add(examRef.id);
            }
            transaction.update(studentRef, {'currentExams': currentExams});
          }
        });
      }

      // Step 5: Success - Close the loading dialog and show success dialog
      print("Firebase operations completed successfully.");
      Navigator.of(loadingContext).pop(); // Close the loading dialog
      _showSuccessDialog(parentContext); // Show success dialog
    } catch (e) {
      // Step 6: Error handling - Close the loading dialog and show error dialog
      print("Error occurred during Firebase operation: $e");
      Navigator.of(loadingContext).pop(); // Close the loading dialog
      _showErrorDialog(
          parentContext, "Failed to publish exam.\nPlease check all inputs.");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorToggle == "light"
              ? AppColorsLight.pure_white
              : AppColorsDark.pure_white, // Set background color to white
          contentPadding: const EdgeInsets.all(40), // Added padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MdiIcons.checkCircleOutline,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Exam ',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black,
                        ),
                      ),
                      TextSpan(
                        text: '"$examName"',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black,
                        ),
                      ),
                      TextSpan(
                        text: '\nSuccessfully created!',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).popUntil((route) => route.isFirst);
                // Use GoRouter's go method to navigate back to the ProfessorScreen
                context.go(
                    '/professor'); // Replace '/professor' with the correct route
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.pure_white,
                backgroundColor: colorToggle == "light"
                    ? AppColorsLight.main_purple
                    : AppColorsDark.main_purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Back to home',
                style: TextStyle(
                  color: colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExamDetails() {
    return ExpansionTile(
      title: Text(
        'Exam Details',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: colorToggle == "light"
              ? AppColorsLight.black
              : AppColorsDark.black,
        ),
      ),
      children: [
        ListTile(
          title: Text(
            'Exam name',
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          subtitle: TextField(
            controller: TextEditingController(text: examName),
            decoration: InputDecoration(
              fillColor: colorToggle == "light"
                  ? AppColorsLight.lightest_grey
                  : AppColorsDark.card_background,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.disabled_grey
                  : AppColorsDark.disabled_grey,
            ),
            enabled: false, // Lock the input box
          ),
        ),
        ListTile(
          title: Text(
            'Course',
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          subtitle: TextField(
            controller: TextEditingController(text: course),
            decoration: InputDecoration(
              fillColor: colorToggle == "light"
                  ? AppColorsLight.lightest_grey
                  : AppColorsDark.card_background,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.disabled_grey
                  : AppColorsDark.disabled_grey,
            ),
            enabled: false, // Lock the input box
          ),
        ),
        ListTile(
          title: Text(
            'Date & time',
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          subtitle: TextField(
            controller: TextEditingController(text: '$date at $time'),
            decoration: InputDecoration(
              fillColor: colorToggle == "light"
                  ? AppColorsLight.lightest_grey
                  : AppColorsDark.card_background,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.disabled_grey
                  : AppColorsDark.disabled_grey,
            ),
            enabled: false, // Lock the input box
          ),
        ),
        ListTile(
          title: Text(
            'Students',
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          subtitle: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorToggle == "light"
                  ? AppColorsLight.lightest_grey
                  : AppColorsDark.card_background,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: colorToggle == "light"
                    ? AppColorsLight.light_grey
                    : AppColorsDark.light_grey,
              ),
            ),
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: students
                  .map((student) => Chip(
                        label: Text(
                          student,
                          style: TextStyle(
                            color: colorToggle == "light"
                                ? AppColorsLight.disabled_grey
                                : AppColorsDark.disabled_grey,
                          ),
                        ),
                        backgroundColor: colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.card_light_background,
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
      title: Text(
        'Add Questions',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: colorToggle == "light"
              ? AppColorsLight.black
              : AppColorsDark.black,
        ),
      ),
      children: questions.map((question) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorToggle == "light"
                  ? AppColorsLight.lightest_grey
                  : AppColorsDark.card_background,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: colorToggle == "light"
                    ? AppColorsLight.light_grey
                    : AppColorsDark.light_grey,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${questions.indexOf(question) + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                    ),
                    Text(
                      '${question['weight']} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorToggle == "light"
                        ? AppColorsLight.light_grey
                        : AppColorsDark.card_light_background,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: colorToggle == "light"
                          ? AppColorsLight.lightest_grey
                          : AppColorsDark.lightest_grey,
                    ),
                  ),
                  child: Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 16.0,
                      color: colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.disabled_grey,
                    ),
                  ),
                ),
                ...question['rubrics'].map<Widget>((rubric) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorToggle == "light"
                            ? AppColorsLight.light_grey
                            : AppColorsDark.light_grey,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: colorToggle == "light"
                              ? AppColorsLight.light_grey
                              : AppColorsDark.light_grey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rubric['rubric'],
                            style: TextStyle(
                              fontSize: 16.0,
                              color: colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.disabled_grey,
                            ),
                          ),
                          Text(
                            '${rubric['weight']} pts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                            ),
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
