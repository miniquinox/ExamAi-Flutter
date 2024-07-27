import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors_professor.dart';
import 'createExam_addQuestions.dart';

class CreateExamDetails extends StatefulWidget {
  final String? examId;
  final String colorToggle; // Add a color parameter

  CreateExamDetails(
      {this.examId, required this.colorToggle}); // Update the constructor

  @override
  _CreateExamDetailsState createState() => _CreateExamDetailsState();
}

class _CreateExamDetailsState extends State<CreateExamDetails> {
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _studentsController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.examId != null) {
      _loadExamData(widget.examId!);
    }
  }

  Future<void> _loadExamData(String examId) async {
    try {
      DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
          .collection('Exams')
          .doc(examId)
          .get();

      if (examSnapshot.exists) {
        Map<String, dynamic> data = examSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _examNameController.text = data['examName'] ?? '';
          _courseController.text = data['course'] ?? '';
          _dateController.text = data['date'] ?? '';
          _timeController.text = data['time'] ?? '';
          _studentsController.text =
              (data['students'] as List<dynamic>).join(', ') ??
                  ''; // Converting list to comma-separated string
        });
      }
    } catch (e) {
      print("Error loading exam data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colorToggle == "light"
          ? AppColorsLight.lightest_grey
          : AppColorsDark.pure_white,
      appBar: AppBar(
        backgroundColor: widget.colorToggle == "light"
            ? AppColorsLight.light_grey
            : AppColorsDark.light_grey,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.home,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            SizedBox(width: 4),
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
              'Create new exam',
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
              child: _buildFormColumn(),
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
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          SizedBox(height: 16),
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
          isActive: _currentStep == 0,
          isCompleted: _currentStep > 0,
        ),
        _buildStep(
          title: 'Add Questions',
          subtitle: 'Create and edit questions',
          isActive: _currentStep == 1,
          isCompleted: _currentStep > 1,
        ),
        _buildStep(
          title: 'Review',
          subtitle: 'Check and review the exam',
          isActive: _currentStep == 2,
          isCompleted: _currentStep > 2,
        )
      ],
    );
  }

  Widget _buildStep(
      {required String title,
      required String subtitle,
      required bool isActive,
      required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isActive
                    ? widget.colorToggle == "light"
                        ? AppColorsLight.main_purple
                        : AppColorsDark.main_purple
                    : isCompleted
                        ? Colors.green
                        : Colors.grey,
                child: Icon(
                  isActive ? Icons.check_circle : Icons.circle,
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
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple
                      : widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive
                      ? widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormColumn() {
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
                color: widget.colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.card_background,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.light_grey
                      : AppColorsDark.light_grey,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Exam Details',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField('Exam name', _examNameController),
                  _buildTextField('Course', _courseController),
                  _buildDateTimeField(
                      'Date', 'Time', _dateController, _timeController),
                  _buildTextField('Students', _studentsController,
                      labelDescription:
                          'Ex: maria@ucdavis.edu, john@gmail.com'),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildButtons(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? labelDescription}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: widget.colorToggle == "light"
                ? AppColorsLight.dark_grey
                : AppColorsDark.black,
          ),
          hintText: labelDescription,
          hintStyle: TextStyle(
            color: widget.colorToggle == "light"
                ? AppColorsLight.dark_grey
                : AppColorsDark.black,
          ),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.light_grey
                  : AppColorsDark.lightest_grey,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
              width: 3.0,
            ),
          ),
        ),
        style: TextStyle(
          color: widget.colorToggle == "light"
              ? AppColorsLight.black
              : AppColorsDark.black,
        ),
        onTap: () {
          // Clear the hintText if it matches the labelDescription when the TextField is tapped
          if (controller.text == labelDescription) {
            controller.clear();
          }
        },
        onEditingComplete: () {
          // Restore the hintText if the TextField is empty when editing is complete
          if (controller.text.isEmpty) {
            controller.text = labelDescription ?? '';
          }
        },
      ),
    );
  }

  Widget _buildDateTimeField(
      String dateLabel,
      String timeLabel,
      TextEditingController dateController,
      TextEditingController timeController) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: dateLabel,
                labelStyle: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.dark_grey
                      : AppColorsDark.black,
                ),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.light_grey
                          : AppColorsDark.lightest_grey,
                      width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                      width: 3.0),
                ),
              ),
              style: TextStyle(
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dateController.text = pickedDate.toString().substring(0, 10);
                }
              },
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: timeLabel,
                labelStyle: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.dark_grey
                      : AppColorsDark.black,
                ),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.light_grey
                          : AppColorsDark.lightest_grey,
                      width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                      width: 3.0),
                ),
              ),
              style: TextStyle(
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
              ),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  timeController.text = pickedTime.format(context);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: widget.colorToggle == "light"
                ? AppColorsLight.black
                : AppColorsDark.black,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: widget.colorToggle == "light"
                ? AppColorsLight.pure_white
                : AppColorsDark.card_background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateExamAddQuestions(
                  examName: _examNameController.text,
                  course: _courseController.text,
                  date: _dateController.text,
                  time: _timeController.text,
                  students: _studentsController.text
                      .split(',')
                      .map((email) => email.trim())
                      .toList(),
                  examId: widget.examId, // Pass the examId here
                  colorToggle: widget.colorToggle, // Pass the colorToggle here
                ),
              ),
            );
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
            'Next',
            style: TextStyle(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark.pure_white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
