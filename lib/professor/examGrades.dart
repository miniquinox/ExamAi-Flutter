import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamDetailsScreen extends StatelessWidget {
  final String examId;

  const ExamDetailsScreen({
    Key? key,
    required this.examId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchStudentDetails() async {
    List<Map<String, dynamic>> studentDetails = [];
    try {
      final examSnapshot = await FirebaseFirestore.instance
          .collection('Exams')
          .doc(examId)
          .collection('graded')
          .get();

      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('Exams')
          .doc(examId)
          .get();

      List<String> questionTitles = [];
      if (questionsSnapshot.exists) {
        final examData = questionsSnapshot.data();
        final questions = examData?['questions'] ?? [];
        for (var question in questions) {
          questionTitles.add(question['question'] ?? 'Placeholder');
        }
      }

      for (var doc in examSnapshot.docs) {
        final data = doc.data();
        final grades = data['grades'] ?? [];
        Map<String, dynamic> studentDetail = {
          'email': doc.id,
          'finalGrade': data['final_grade']?.toString() ?? 'Placeholder',
        };

        for (var i = 0; i < questionTitles.length; i++) {
          studentDetail['q${i + 1}'] = grades.length > i
              ? grades[i]['total_score']?.toString() ?? 'Placeholder'
              : 'Placeholder';
        }

        studentDetails.add(studentDetail);
      }
    } catch (e) {
      // Handle error
    }
    return studentDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: const Text('Your exams details'),
        backgroundColor: const Color(0xFFFCFCFD),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchStudentDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading exam details'));
          } else {
            final studentDetails = snapshot.data ?? [];
            if (studentDetails.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Align the children to the center
                  children: <Widget>[
                    Text(
                      'No exam data yet',
                      style: TextStyle(
                        fontSize: 24, // Adjust the font size as needed
                        fontWeight: FontWeight.bold, // Make the text bold
                        color: Colors.grey, // Set the text color
                      ),
                    ),
                    SizedBox(
                        height:
                            20), // Add some space between the text and the image
                    Image.asset(
                      'assets/images/noExams.png',
                      height: 300,
                    ),
                  ],
                ),
              );
            }
            final questionColumns = studentDetails.isNotEmpty
                ? List.generate(
                    studentDetails[0].length - 2,
                    (index) => DataColumn(
                          label: Text('Q${index + 1} (20 pts)'),
                        ))
                : [];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Student email')),
                      ...questionColumns,
                      const DataColumn(label: Text('Final grades (100 pts)')),
                      const DataColumn(label: Text('')),
                    ],
                    rows: studentDetails
                        .map(
                          (student) => DataRow(cells: [
                            DataCell(Text(student['email'] ?? 'Placeholder')),
                            ...List.generate(
                                student.length - 2,
                                (index) => DataCell(Text(
                                    student['q${index + 1}'] ??
                                        'Placeholder'))),
                            DataCell(Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: SizedBox(
                                      height: 10,
                                      child: LinearProgressIndicator(
                                        value: (student['finalGrade'] !=
                                                    'Placeholder'
                                                ? double.parse(
                                                        student['finalGrade']) /
                                                    100
                                                : 0.0)
                                            .toDouble(),
                                        backgroundColor: Colors.grey.shade300,
                                        color: Color(0xFF6539EF),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(student['finalGrade']),
                              ],
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Handle edit action
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    // Handle delete action
                                  },
                                ),
                              ],
                            )),
                          ]),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// Sample usage of the ExamDetailsScreen
void main() {
  runApp(MaterialApp(
    home: ExamDetailsScreen(
      examId: 'exam123',
    ),
  ));
}
