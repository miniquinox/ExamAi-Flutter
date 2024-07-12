import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

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

  Future<List<Map<String, dynamic>>> fetchGrades(String examId) async {
    final gradesSnapshot = await FirebaseFirestore.instance
        .collection('Exams')
        .doc(examId)
        .collection('graded')
        .get();

    List<Map<String, dynamic>> grades = [];
    for (var doc in gradesSnapshot.docs) {
      double grade = (doc.data()['final_grade'] ?? 0).toDouble();
      String email = doc.id;
      grades.add({'email': email, 'grade': grade});
    }
    return grades;
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
        final List<dynamic> questionsDynamic = examDetails['questions'] ?? [];
        final List<Map<String, dynamic>> questions = questionsDynamic
            .map((question) => Map<String, dynamic>.from(question))
            .toList();
        final int questionCount = questions.length;
        final int totalStudents = (examDetails['students'] as List).length;
        final int totalScore = questions.fold<int>(
            0, (sum, question) => sum + (question['weight'] as int? ?? 0));
        final int passingGrade = (totalScore * 0.7).round();

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchGrades(examId),
          builder: (context, gradesSnapshot) {
            if (gradesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (gradesSnapshot.hasError) {
              return Center(child: Text('Error loading grades'));
            } else if (!gradesSnapshot.hasData ||
                gradesSnapshot.data!.isEmpty) {
              return Center(child: Text('No grades found'));
            }

            final List<Map<String, dynamic>> grades = gradesSnapshot.data!;

            // Debug print for grades
            print("Grades and student emails:");
            grades.forEach((student) {
              print("${student['email']}: ${student['grade']}");
            });

            // Debug print for grade distribution
            Map<String, int> gradeDistribution = {
              '0-10%': 0,
              '10-20%': 0,
              '20-30%': 0,
              '30-40%': 0,
              '40-50%': 0,
              '50-60%': 0,
              '60-70%': 0,
              '70-80%': 0,
              '80-90%': 0,
              '90-100%': 0,
            };

            for (var student in grades) {
              double grade = student['grade'];
              if (grade < 10)
                gradeDistribution['0-10%'] = gradeDistribution['0-10%']! + 1;
              else if (grade < 20)
                gradeDistribution['10-20%'] = gradeDistribution['10-20%']! + 1;
              else if (grade < 30)
                gradeDistribution['20-30%'] = gradeDistribution['20-30%']! + 1;
              else if (grade < 40)
                gradeDistribution['30-40%'] = gradeDistribution['30-40%']! + 1;
              else if (grade < 50)
                gradeDistribution['40-50%'] = gradeDistribution['40-50%']! + 1;
              else if (grade < 60)
                gradeDistribution['50-60%'] = gradeDistribution['50-60%']! + 1;
              else if (grade < 70)
                gradeDistribution['60-70%'] = gradeDistribution['60-70%']! + 1;
              else if (grade < 80)
                gradeDistribution['70-80%'] = gradeDistribution['70-80%']! + 1;
              else if (grade < 90)
                gradeDistribution['80-90%'] = gradeDistribution['80-90%']! + 1;
              else
                gradeDistribution['90-100%'] =
                    gradeDistribution['90-100%']! + 1;
            }

            print("Grade distribution:");
            gradeDistribution.forEach((range, count) {
              print("$range: $count");
            });

            return Scaffold(
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
                      'Exams',
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
              backgroundColor: Color(0xFFFCFCFE),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text('Overview',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold)),
                    Text(
                      'We graded your class exams and these are the results...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 20),

                    // Exam details section
                    Row(
                      children: [
                        // Column 1: Course, Exam Name, Questions
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(course,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'Exam:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: ' $examName',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'Questions:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: ' $questionCount',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Column 2: Time Length
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildIconTextButton(Icons.access_time,
                                  '${examDetails['time_length'] ?? 'Placeholder'} hrs'),
                            ],
                          ),
                        ),
                        // Column 3: Total score and date/time
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildIconTextButton(Icons.check_circle,
                                  'Total: $totalScore (pass marks: $passingGrade)'),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                      '${examDetails['date'] ?? 'Placeholder'}'),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward, size: 20.0),
                                  SizedBox(width: 5),
                                  Text(
                                      '${examDetails['time'] ?? 'Placeholder'}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Statistics section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatBox('Total students',
                            totalStudents.toString(), Icons.people),
                        SizedBox(width: 10),
                        _buildStatBox(
                            'Absent students', 'Placeholder', Icons.person_off),
                        SizedBox(width: 10),
                        _buildStatBox(
                            'Average score', 'Placeholder', Icons.score),
                        SizedBox(width: 10),
                        _buildStatBox('Passed students', 'Placeholder',
                            Icons.check_circle),
                        SizedBox(width: 10),
                        _buildStatBox(
                            'Failed students', 'Placeholder', Icons.cancel),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Grade distribution graphs and top students sections
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildGraphBox('Grade distribution',
                                  _buildGradeDistributionChart(grades)),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: _buildTopStudentsBox(),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildGraphBox('Grade distribution'),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: _buildHardestQuestionsBox(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconTextButton(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE9EAED), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFF6938EF)),
          SizedBox(width: 8),
          Text(text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFE9EAED), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFF6938EF),
                  ),
                ),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphBox(String title, [Widget? content]) {
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
          content ?? Center(child: Text("Placeholder")),
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

  Widget _buildGradeDistributionChart(List<Map<String, dynamic>> grades) {
    if (grades.isEmpty) {
      return Center(child: Text("No data available"));
    }

    Map<String, int> gradeDistribution = {
      '0-10%': 0,
      '10-20%': 0,
      '20-30%': 0,
      '30-40%': 0,
      '40-50%': 0,
      '50-60%': 0,
      '60-70%': 0,
      '70-80%': 0,
      '80-90%': 0,
      '90-100%': 0,
    };

    for (var student in grades) {
      double grade = student['grade'];
      if (grade < 10)
        gradeDistribution['0-10%'] = gradeDistribution['0-10%']! + 1;
      else if (grade < 20)
        gradeDistribution['10-20%'] = gradeDistribution['10-20%']! + 1;
      else if (grade < 30)
        gradeDistribution['20-30%'] = gradeDistribution['20-30%']! + 1;
      else if (grade < 40)
        gradeDistribution['30-40%'] = gradeDistribution['30-40%']! + 1;
      else if (grade < 50)
        gradeDistribution['40-50%'] = gradeDistribution['40-50%']! + 1;
      else if (grade < 60)
        gradeDistribution['50-60%'] = gradeDistribution['50-60%']! + 1;
      else if (grade < 70)
        gradeDistribution['60-70%'] = gradeDistribution['60-70%']! + 1;
      else if (grade < 80)
        gradeDistribution['70-80%'] = gradeDistribution['70-80%']! + 1;
      else if (grade < 90)
        gradeDistribution['80-90%'] = gradeDistribution['80-90%']! + 1;
      else
        gradeDistribution['90-100%'] = gradeDistribution['90-100%']! + 1;
    }

    List<BarChartGroupData> barGroups = gradeDistribution.entries.map((entry) {
      int index = gradeDistribution.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Color(0xff9b8afb), // Lighter purple color
            width: 30, // Wider bars
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ), // Rounded top corners
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 250, // Set the chart height to 250
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0), // Adjusted bottom padding
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    const style = TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Adjusted font size
                    );
                    List<String> titles = gradeDistribution.keys.toList();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8.0, // Adjusted space between titles
                      child: Text(titles[value.toInt()], style: style),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey,
              ),
            ),
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }
}
