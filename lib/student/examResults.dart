import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamResultsScreen extends StatelessWidget {
  final String examId;

  const ExamResultsScreen({Key? key, required this.examId}) : super(key: key);

  Future<Map<String, dynamic>> fetchExamDetails(String examId) async {
    final examSnapshot =
        await FirebaseFirestore.instance.collection('Exams').doc(examId).get();

    if (examSnapshot.exists) {
      return examSnapshot.data()!;
    } else {
      return {};
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
        final String course = examDetails['course'] ?? 'Placeholder';
        final String examName = examDetails['examName'] ?? 'Placeholder';
        final int questionCount = (examDetails['questions'] as List).length;
        final int totalStudents = (examDetails['students'] as List).length;

        return Scaffold(
          backgroundColor: Color(0xFFFCFCFE),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Overview',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'We graded your class exams and these are the results...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),

                // Exam details section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFE9EAED), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text('Exam: $examName', style: TextStyle(fontSize: 16)),
                      Text('Questions: $questionCount',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Statistics section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatBox('Total students', totalStudents.toString()),
                    _buildStatBox('Absent students', 'Placeholder'),
                    _buildStatBox('Average score', 'Placeholder'),
                    _buildStatBox('Passed students', 'Placeholder'),
                    _buildStatBox('Failed students', 'Placeholder'),
                  ],
                ),
                SizedBox(height: 20),

                // Grade distribution graph
                _buildGraphBox('Grad distribution', 'Placeholder'),
                SizedBox(height: 20),

                // Top 3 students section
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTopStudentsBox(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: _buildHardestQuestionsBox(),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Grade distribution graph (bottom)
                _buildGraphBox('Grad distribution', 'Placeholder'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE9EAED), width: 1),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGraphBox(String title, String placeholder) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE9EAED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Center(child: Text(placeholder)),
        ],
      ),
    );
  }

  Widget _buildTopStudentsBox() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE9EAED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top 3 students',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Center(child: Text('Placeholder')),
        ],
      ),
    );
  }

  Widget _buildHardestQuestionsBox() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE9EAED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top hardest questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('1. Placeholder question', style: TextStyle(fontSize: 16)),
          Text('2. Placeholder question', style: TextStyle(fontSize: 16)),
          Text('3. Placeholder question', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
