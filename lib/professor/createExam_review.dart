import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateExamReview extends StatelessWidget {
  final String examName;
  final String course;
  final String date;
  final String time;
  final List<String> students;
  final List<Map<String, dynamic>> questions;

  const CreateExamReview({
    required this.examName,
    required this.course,
    required this.date,
    required this.time,
    required this.students,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.home, color: Colors.black),
            SizedBox(width: 4),
            Text(
              'Home',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.black),
            SizedBox(width: 4),
            Icon(Icons.assignment, color: Color(0xFF6938EF)),
            SizedBox(width: 4),
            Text(
              'Create new exam',
              style: TextStyle(color: Color(0xFF6938EF)),
            ),
            Spacer(),
            CircleAvatar(
              backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? ''),
              backgroundColor: Colors.transparent,
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
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
      width: 200,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        ),
        _buildStep(
          title: 'Publish',
          subtitle: 'Publish the exam to students',
          isActive: false,
          isCompleted: false,
        ),
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
                    ? Colors.purple
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
                  color: isActive ? Colors.purple : Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.purpleAccent : Colors.grey,
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
                  Text('Review',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildExamDetails(),
                          SizedBox(height: 16),
                          _buildAddQuestions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Publish
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF6938EF),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Publish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamDetails() {
    return ExpansionTile(
      title: Text('Exam Details',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      children: [
        ListTile(
          title: Text('Exam name'),
          subtitle: TextField(
            controller: TextEditingController(text: examName),
            decoration: InputDecoration(
              fillColor: Color(0xfff2f4f7),
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
          title: Text('Course'),
          subtitle: TextField(
            controller: TextEditingController(text: course),
            decoration: InputDecoration(
              fillColor: Color(0xfff2f4f7),
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
          title: Text('Date & time'),
          subtitle: TextField(
            controller: TextEditingController(text: '$date at $time'),
            decoration: InputDecoration(
              fillColor: Color(0xfff2f4f7),
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
          title: Text('Students'),
          subtitle: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xfff2f4f7),
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
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddQuestions() {
    return ExpansionTile(
      title: Text(
        'Add Questions',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      children: questions.map((question) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xfffcfcfd),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Color(0xffcbcfd7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${questions.indexOf(question) + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${question['weight']} pts',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xfff1f1f5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    question['question'],
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                ...question['rubrics'].map<Widget>((rubric) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xfff1f1f5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rubric['rubric'],
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            '${rubric['weight']} pts',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

void main() => runApp(MaterialApp(
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
