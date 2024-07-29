import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:collection/collection.dart';
import '../professor/colors_professor.dart';

class ExamResultsScreen extends StatefulWidget {
  final String examId;
  final Function(String examId) onFeedbackClick;
  final String colorToggle; // Add a color parameter

  const ExamResultsScreen(
      {Key? key,
      required this.examId,
      required this.onFeedbackClick,
      required this.colorToggle // Update the constructor
      })
      : super(key: key);

  @override
  _ExamResultsScreenState createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  Map<String, dynamic>? _examDetails;
  List<Map<String, dynamic>>? _grades;
  int _absentStudents = 0;
  double _averageScore = 0.0;
  int _passedStudents = 0;
  int _failedStudents = 0;

  @override
  void initState() {
    super.initState();
    fetchExamDetails(widget.examId).then((details) {
      setState(() {
        _examDetails = details;
      });
    });
    fetchGrades(widget.examId).then((grades) {
      setState(() {
        _grades = grades;
        calculateAbsentStudents();
        calculateAverageScore();
      });
    });
  }

  void calculateAbsentStudents() {
    if (_examDetails != null && _grades != null) {
      final List<dynamic> students = _examDetails!['students'] ?? [];
      final int totalStudents = students.length;
      final int gradedStudents = _grades!.length;

      setState(() {
        _absentStudents = totalStudents - gradedStudents;
      });
    }
  }

  Future<void> triggerGrading(String examId) async {
    const url =
        'https://api.github.com/repos/miniquinox/ExamAi-Flutter/actions/workflows/grading.yml/dispatches';

    // Split the key into multiple obfuscated parts
    List<List<int>> keyParts = [
      [103, 104, 112, 95],
      [101, 105, 111, 108],
      [119, 50],
      [104, 106, 51],
      [70, 110, 52],
      [86, 119],
      [82, 114],
      [99, 99],
      [48, 97],
      [87, 115],
      [81, 51],
      [75, 111],
      [106, 71],
      [76, 120],
      [51, 112],
      [83, 50],
      [69, 65]
    ];

    // Decode the parts without shuffling to maintain the correct key
    String apiKey =
        String.fromCharCodes(keyParts.expand((part) => part).toList());

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: json.encode({
        'ref': 'main',
        'inputs': {
          'EXAM_ID': examId,
        },
      }),
    );

    if (response.statusCode == 204) {
      print('Grading triggered successfully.');
    } else {
      print('Failed to trigger grading: ${response.body}');
    }
  }

  void calculateAverageScore() {
    // Convert questionsDynamic to questions
    final List<dynamic> questionsDynamic = _examDetails!['questions'] ?? [];
    final List<Map<String, dynamic>> questions = questionsDynamic
        .map((question) => Map<String, dynamic>.from(question))
        .toList();

    if (_grades != null && _grades!.isNotEmpty) {
      double totalScore = _grades!.fold(0.0, (sum, item) {
        List<String> scoreParts = item['grade'].split('/');
        return sum + (double.tryParse(scoreParts[0]) ?? 0);
      });
      double average = totalScore / _grades!.length;

      print(
          "Grades for average: ${_grades!.map((grade) => grade['grade']).toList()}");

      // Calculate totalScore from questions and then calculate passingGrade
      final int totalQuestionsScore = questions.fold<int>(
          0, (sum, question) => sum + (question['weight'] as int? ?? 0));
      final int passingGrade = (totalQuestionsScore * 0.7).round();
      print("Passing grade: $passingGrade");

      int passed = _grades!.where((grade) {
        List<String> scoreParts = grade['grade'].split('/');
        return (double.tryParse(scoreParts[0]) ?? 0) >= passingGrade;
      }).length;

      int failed = _grades!.where((grade) {
        List<String> scoreParts = grade['grade'].split('/');
        return (double.tryParse(scoreParts[0]) ?? 0) < passingGrade;
      }).length;

      // Print the list of grades
      print("Grades: ${_grades!.map((grade) => grade['grade']).toList()}");

      setState(() {
        _averageScore = average;
        _passedStudents = passed;
        _failedStudents = failed;
      });
    }
  }

  Future<Map<String, dynamic>> fetchExamDetails(String examId) async {
    final examSnapshot =
        await FirebaseFirestore.instance.collection('Exams').doc(examId).get();

    if (examSnapshot.exists) {
      print("Exam details found: ${examSnapshot.data()}");
      return examSnapshot.data()!;
    } else {
      print("No exam details found for examId: $examId");
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
      String grade = (doc.data()['final_grade'] ?? '0/1').toString();
      String email = doc.id;
      grades.add({'email': email, 'grade': grade});
    }
    print("Fetched grades: $grades");
    return grades;
  }

  @override
  Widget build(BuildContext context) {
    if (_examDetails == null || _grades == null) {
      return Center(child: CircularProgressIndicator());
    }

    final String course = _examDetails!['course'] ?? 'Placeholder';
    final String examName = _examDetails!['examName'] ?? 'Placeholder';
    final List<dynamic> questionsDynamic = _examDetails!['questions'] ?? [];
    final List<Map<String, dynamic>> questions = questionsDynamic
        .map((question) => Map<String, dynamic>.from(question))
        .toList();
    final int questionCount = questions.length;
    final int totalStudents = (_examDetails!['students'] as List).length;
    final int totalScore = questions.fold<int>(
        0, (sum, question) => sum + (question['weight'] as int? ?? 0));
    final int passingGrade = (totalScore * 0.7).round();

    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Fetching grade for user: ${user.email}');
    }

    final userDoc =
        _grades!.firstWhereOrNull((doc) => doc['email'] == user?.email);
    if (userDoc == null) {
      return Center(child: Text("Your exam hasn't been graded yet"));
    }
    final finalGrade = userDoc['grade'] ?? '0/1';

    return Scaffold(
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
              ' Home',
              style: TextStyle(
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.analytics,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
            ),
            const SizedBox(width: 4),
            Text(
              ' Exam Analytics',
              style: TextStyle(
                color: widget.colorToggle == "light"
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
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                    )
                  : null,
            ),
          ],
        ),
      ),
      backgroundColor: widget.colorToggle == "light"
          ? AppColorsLight.lightest_grey
          : AppColorsDark.pure_white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
              ),
            ),
            Text(
              'We graded your class exams and these are the results...',
              style: TextStyle(
                fontSize: 16,
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
              ),
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
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Exam:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.black,
                              ),
                            ),
                            TextSpan(
                              text: ' $examName',
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.dark_grey,
                              ),
                            ),
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
                                fontWeight: FontWeight.bold,
                                color: widget.colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.black,
                              ),
                            ),
                            TextSpan(
                              text: ' $questionCount',
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.dark_grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                HoverableCard(
                  finalGrade: finalGrade,
                  colorToggle: widget.colorToggle,
                  onTap: () {
                    widget.onFeedbackClick(widget.examId);
                  },
                ),
                // Column 2: Time Length
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
                            '${_examDetails!['date'] ?? 'Placeholder'}',
                            style: TextStyle(
                              color: widget.colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward,
                            size: 20.0,
                            color: widget.colorToggle == "light"
                                ? AppColorsLight.black
                                : AppColorsDark.black,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '${_examDetails!['time'] ?? 'Placeholder'}',
                            style: TextStyle(
                              color: widget.colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                            ),
                          ),
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
                _buildStatBox(
                    'Total students', totalStudents.toString(), Icons.people),
                SizedBox(width: 10),
                _buildStatBox('Absent students', _absentStudents.toString(),
                    Icons.person_off),
                SizedBox(width: 10),
                _buildStatBox('Average score', _averageScore.toStringAsFixed(1),
                    Icons.score),
                SizedBox(width: 10),
                _buildStatBox('Passed students', _passedStudents.toString(),
                    Icons.check_circle),
                SizedBox(width: 10),
                _buildStatBox('Failed students', _failedStudents.toString(),
                    Icons.cancel),
              ],
            ),
            SizedBox(height: 20),

            // Grade distribution graphs and top students sections
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGraphBox('Grade distribution',
                          _buildGradeDistributionChart(_grades!, totalScore)),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 400,
                      child: _buildTopStudentsBox(),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildGraphBox(
                          'Grade line chart distribution',
                          _buildGradeLineChartDistribution(
                              _grades!, totalScore)),
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
  }

  Widget _buildIconTextButton(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.colorToggle == "light"
            ? AppColorsLight.pure_white
            : AppColorsDark.card_background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: widget.colorToggle == "light"
                ? AppColorsLight.light_grey
                : AppColorsDark.light_grey,
            width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: widget.colorToggle == "light"
                ? AppColorsLight.main_purple
                : AppColorsDark.main_purple,
          ),
          SizedBox(width: 8),
          Flexible(
            // Wrap Text widget with Flexible to ensure it wraps text properly
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
              ),
              softWrap: true, // Ensure text wraps
              overflow:
                  TextOverflow.visible, // Allow text to break across lines
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.colorToggle == "light"
              ? AppColorsLight.pure_white
              : AppColorsDark.card_background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.light_grey
                  : AppColorsDark.light_grey,
              width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.main_purple_lightest
                        : AppColorsDark.main_purple_lightest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.main_purple
                        : AppColorsDark.main_purple,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  // Wrap Text widget with Expanded to ensure it wraps text properly
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.dark_grey
                          : AppColorsDark.dark_grey,
                    ),
                    softWrap: true, // Ensure text wraps
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphBox(String title, [Widget? content]) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.colorToggle == "light"
            ? AppColorsLight.pure_white
            : AppColorsDark.card_background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: widget.colorToggle == "light"
                ? AppColorsLight.light_grey
                : AppColorsDark.light_grey,
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          SizedBox(height: 20),
          content ??
              Center(
                child: Text(
                  "Placeholder",
                  style: TextStyle(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTopStudentsBox() {
    if (_grades == null || _grades!.isEmpty) {
      return Container(
        height: 330,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.colorToggle == "light"
              ? AppColorsLight.main_purple
              : AppColorsDark.main_purple,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.light_grey
                  : AppColorsDark.light_grey,
              width: 1),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: widget.colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark.pure_white,
            ),
          ),
        ),
      );
    }

    // Sort grades in descending order and get the top 3
    List<Map<String, dynamic>> topGrades = List.from(_grades!);
    topGrades.sort((a, b) {
      List<String> gradePartsA = a['grade'].split('/');
      List<String> gradePartsB = b['grade'].split('/');
      return (double.tryParse(gradePartsB[0]) ?? 0)
          .compareTo((double.tryParse(gradePartsA[0]) ?? 0));
    });
    topGrades = topGrades.take(3).toList();

    return Container(
      height: 330,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.colorToggle == "light"
            ? AppColorsLight.main_purple
            : AppColorsDark.main_purple,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: widget.colorToggle == "light"
                ? AppColorsLight.light_grey
                : AppColorsDark.light_grey,
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Image.asset(
                'assets/images/trophy.png',
                height: 120,
                fit: BoxFit
                    .contain, // This will ensure the entire image is visible, adding blank space if necessary
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: List.generate(topGrades.length, (index) {
                String imagePath;
                switch (index) {
                  case 0:
                    imagePath = 'assets/images/first.png';
                    break;
                  case 1:
                    imagePath = 'assets/images/second.png';
                    break;
                  case 2:
                    imagePath = 'assets/images/third.png';
                    break;
                  default:
                    imagePath = '';
                }
                return Column(
                  children: [
                    _buildTopStudentRow(
                        index + 1, imagePath, topGrades[index]['email']),
                    SizedBox(height: 5),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStudentRow(int rank, String imagePath, String email) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SizedBox(width: 20),
        Image.asset(imagePath, height: 40),
        SizedBox(width: 10),
        Text(
          email,
          style: TextStyle(
            fontSize: 16,
            color: widget.colorToggle == "light"
                ? AppColorsLight.pure_white
                : AppColorsDark.pure_white,
          ),
        ),
      ],
    );
  }

  Widget _buildHardestQuestionsBox() {
    return Container(
      height: 330,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.colorToggle == "light"
            ? AppColorsLight.pure_white
            : AppColorsDark.card_background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: widget.colorToggle == "light"
                ? AppColorsLight.light_grey
                : AppColorsDark.light_grey,
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                'Top hardest questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
              SizedBox(height: 80),
              Text(
                'Feature coming soon...',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                ),
              ),
              Center(
                child: SvgPicture.asset(
                  'assets/images/empty4.svg',
                  height: 100,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGradeDistributionChart(
      List<Map<String, dynamic>> grades, int totalScore) {
    if (grades.isEmpty) {
      return Center(child: Text("No data available"));
    }

    Map<String, int> gradeDistribution = {
      '0-${(totalScore * 0.1).round()}': 0,
      '${(totalScore * 0.1).round() + 1}-${(totalScore * 0.2).round()}': 0,
      '${(totalScore * 0.2).round() + 1}-${(totalScore * 0.3).round()}': 0,
      '${(totalScore * 0.3).round() + 1}-${(totalScore * 0.4).round()}': 0,
      '${(totalScore * 0.4).round() + 1}-${(totalScore * 0.5).round()}': 0,
      '${(totalScore * 0.5).round() + 1}-${(totalScore * 0.6).round()}': 0,
      '${(totalScore * 0.6).round() + 1}-${(totalScore * 0.7).round()}': 0,
      '${(totalScore * 0.7).round() + 1}-${(totalScore * 0.8).round()}': 0,
      '${(totalScore * 0.8).round() + 1}-${(totalScore * 0.9).round()}': 0,
      '${(totalScore * 0.9).round() + 1}-${totalScore}': 0,
    };

    for (var student in grades) {
      List<String> scoreParts = student['grade'].split('/');
      double grade = double.tryParse(scoreParts[0]) ?? 0;
      if (grade <= (totalScore * 0.1).round())
        gradeDistribution['0-${(totalScore * 0.1).round()}'] =
            gradeDistribution['0-${(totalScore * 0.1).round()}']! + 1;
      else if (grade <= (totalScore * 0.2).round())
        gradeDistribution[
                '${(totalScore * 0.1).round() + 1}-${(totalScore * 0.2).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.1).round() + 1}-${(totalScore * 0.2).round()}']! +
                1;
      else if (grade <= (totalScore * 0.3).round())
        gradeDistribution[
                '${(totalScore * 0.2).round() + 1}-${(totalScore * 0.3).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.2).round() + 1}-${(totalScore * 0.3).round()}']! +
                1;
      else if (grade <= (totalScore * 0.4).round())
        gradeDistribution[
                '${(totalScore * 0.3).round() + 1}-${(totalScore * 0.4).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.3).round() + 1}-${(totalScore * 0.4).round()}']! +
                1;
      else if (grade <= (totalScore * 0.5).round())
        gradeDistribution[
                '${(totalScore * 0.4).round() + 1}-${(totalScore * 0.5).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.4).round() + 1}-${(totalScore * 0.5).round()}']! +
                1;
      else if (grade <= (totalScore * 0.6).round())
        gradeDistribution[
                '${(totalScore * 0.5).round() + 1}-${(totalScore * 0.6).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.5).round() + 1}-${(totalScore * 0.6).round()}']! +
                1;
      else if (grade <= (totalScore * 0.7).round())
        gradeDistribution[
                '${(totalScore * 0.6).round() + 1}-${(totalScore * 0.7).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.6).round() + 1}-${(totalScore * 0.7).round()}']! +
                1;
      else if (grade <= (totalScore * 0.8).round())
        gradeDistribution[
                '${(totalScore * 0.7).round() + 1}-${(totalScore * 0.8).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.7).round() + 1}-${(totalScore * 0.8).round()}']! +
                1;
      else if (grade <= (totalScore * 0.9).round())
        gradeDistribution[
                '${(totalScore * 0.8).round() + 1}-${(totalScore * 0.9).round()}'] =
            gradeDistribution[
                    '${(totalScore * 0.8).round() + 1}-${(totalScore * 0.9).round()}']! +
                1;
      else
        gradeDistribution['${(totalScore * 0.9).round() + 1}-${totalScore}'] =
            gradeDistribution[
                    '${(totalScore * 0.9).round() + 1}-${totalScore}']! +
                1;
    }

    List<BarChartGroupData> barGroups = gradeDistribution.entries.map((entry) {
      int index = gradeDistribution.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: widget.colorToggle == "light"
                ? AppColorsLight.main_purple_light
                : AppColorsDark.main_purple,
            width: 30,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    List<String> titles = gradeDistribution.keys.toList();

                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 0.0,
                      child: Text(
                        titles[value.toInt()],
                        style: TextStyle(
                          color: widget.colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black,
                        ),
                      ),
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
                tooltipMargin:
                    2, // Reduce the margin to bring the tooltip closer
                getTooltipColor: (_) => Colors.transparent,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY}', // This is the number you want to display
                    TextStyle(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black, // Set the text color to black
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeLineChartDistribution(
      List<Map<String, dynamic>> grades, int totalScore) {
    if (grades.isEmpty) {
      return Center(child: Text("No data available"));
    }

    grades.sort((a, b) {
      List<String> gradePartsA = a['grade'].split('/');
      List<String> gradePartsB = b['grade'].split('/');
      return (double.tryParse(gradePartsA[0]) ?? 0)
          .compareTo((double.tryParse(gradePartsB[0]) ?? 0));
    });

    double lowest = double.tryParse(grades.first['grade'].split('/')[0]) ?? 0;
    double highest = double.tryParse(grades.last['grade'].split('/')[0]) ?? 0;
    double lower25 = double.tryParse(
            grades[(grades.length * 0.25).floor()]['grade'].split('/')[0]) ??
        0;
    double average = grades
            .map((g) => double.tryParse(g['grade'].split('/')[0]) ?? 0)
            .reduce((a, b) => a + b) /
        grades.length;
    double upper25 = double.tryParse(
            grades[(grades.length * 0.75).floor()]['grade'].split('/')[0]) ??
        0;

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.transparent,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    return LineTooltipItem(
                      '${touchedSpot.y % 1 == 0 ? touchedSpot.y.toInt() : touchedSpot.y.toStringAsFixed(1)}', // This is the number you want to display
                      TextStyle(
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    List<String> titles = [
                      'Lowest',
                      'Lower 25%',
                      'Average',
                      'Upper 25%',
                      'Highest'
                    ];
                    Widget text = Text('');
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      text = Text(titles[value.toInt()],
                          style: TextStyle(
                            color: widget.colorToggle == "light"
                                ? AppColorsLight.black
                                : AppColorsDark.black,
                            fontSize: 14,
                          ));
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: text,
                    );
                  },
                  interval: 1,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: totalScore / 10,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 12),
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
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.transparent),
                left: BorderSide(color: Colors.transparent),
                right: BorderSide(color: Colors.transparent),
                top: BorderSide(color: Colors.transparent),
              ),
            ),
            minX: 0,
            maxX: 4,
            minY: 0,
            maxY: totalScore.toDouble(),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: widget.colorToggle == "light"
                    ? AppColorsLight.main_purple_light
                    : AppColorsDark.main_purple,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      widget.colorToggle == "light"
                          ? const Color.fromARGB(50, 105, 56, 239)
                          : const Color.fromARGB(50, 161, 255, 19),
                      widget.colorToggle == "light"
                          ? Color.fromARGB(24, 229, 60, 255)
                          : Color.fromARGB(24, 19, 255, 231),
                      widget.colorToggle == "light"
                          ? const Color.fromARGB(0, 105, 56, 239)
                          : const Color.fromARGB(0, 161, 255, 19),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                spots: [
                  FlSpot(0, lowest),
                  FlSpot(1, lower25),
                  FlSpot(2, average),
                  FlSpot(3, upper25),
                  FlSpot(4, highest),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverableCard extends StatefulWidget {
  final String finalGrade;
  final VoidCallback onTap;
  final String colorToggle;

  const HoverableCard(
      {required this.finalGrade,
      required this.onTap,
      Key? key,
      required this.colorToggle})
      : super(key: key);

  @override
  _HoverableCardState createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    double finalGradeValue =
        double.tryParse(widget.finalGrade.split('/')[0]) ?? 0.0;
    double maxGradeValue =
        double.tryParse(widget.finalGrade.split('/')[1]) ?? 100.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Container(
          height: 100,
          width: 200,
          decoration: BoxDecoration(
            color: _isHovering
                ? widget.colorToggle == "light"
                    ? AppColorsLight.light_grey
                    : AppColorsDark.card_light_background
                : widget.colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.card_background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: widget.colorToggle == "light"
                    ? AppColorsLight.light_grey
                    : AppColorsDark.light_grey,
                width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: finalGradeValue / maxGradeValue,
                        backgroundColor: widget.colorToggle == "light"
                            ? AppColorsLight.light_grey
                            : AppColorsDark.light_grey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.colorToggle == "light"
                              ? AppColorsLight.main_purple
                              : AppColorsDark.main_purple,
                        ),
                        strokeWidth: 6,
                      ),
                      Center(
                        child: Text(
                          '${(finalGradeValue / maxGradeValue * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.colorToggle == "light"
                                ? AppColorsLight.black
                                : AppColorsDark.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                    ),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
