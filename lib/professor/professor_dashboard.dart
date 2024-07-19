import 'package:examai_flutter/main.dart';
import 'package:examai_flutter/professor/ExamResults_professor.dart';
import 'package:examai_flutter/professor/createExam_examDetails.dart';
import 'package:examai_flutter/professor/examGrades.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProfessorScreen(),
    );
  }
}

class ProfessorScreen extends StatefulWidget {
  const ProfessorScreen({super.key});

  @override
  _ProfessorScreenState createState() => _ProfessorScreenState();
}

class _ProfessorScreenState extends State<ProfessorScreen> {
  User? user;
  int totalExamsCreated = 0;
  int totalExamsTaken = 0;
  int totalQuestions = 0;
  List<Map<String, dynamic>> exams = [];
  Set<String> students = {}; // Using Set to ensure uniqueness
  String? selectedExamId; // Add this line to track the selected exam ID
  bool showExamResults =
      false; // Add this line to toggle between exam details and results
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController
  Map<DateTime, int> _questionsPerDate = {}; // Declare the variable here

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchTotalExams();
    fetchQuestionsPerDate();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  Future<void> fetchUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      user = currentUser;
    });
    fetchTotalExams();
    fetchTotalExamsTaken();
    fetchExams();
    fetchTotalQuestions();
    fetchStudents(); // Fetch students when the user is fetched
  }

  Future<Map<DateTime, int>> questionsPerDate() async {
    Map<DateTime, int> questionsCountPerDate = {};

    if (user != null) {
      DocumentSnapshot professorSnapshot = await FirebaseFirestore.instance
          .collection('Professors')
          .doc(user!.email)
          .get();
      if (professorSnapshot.exists) {
        List<dynamic> currentExams =
            professorSnapshot.get('currentExams') ?? [];

        for (String examId in currentExams) {
          DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
              .collection('Exams')
              .doc(examId)
              .get();

          if (examSnapshot.exists) {
            // Print the exam ID
            print('Exam ID: $examId');

            if ((examSnapshot.data() as Map<String, dynamic>)
                .containsKey('dateLastGraded')) {
              try {
                String dateStr = examSnapshot.get('dateLastGraded');
                // Print the dateLastGraded string
                print('dateLastGraded: $dateStr');

                // Append the current year to the date string
                String currentYear = DateTime.now().year.toString();
                String fullDateStr = '$dateStr $currentYear';

                DateTime dateGraded =
                    DateFormat('MMMM d\'th\' \'at\' h:mma yyyy')
                        .parse(fullDateStr);

                List<dynamic> questions = examSnapshot.get('questions') ?? [];
                List<dynamic> students = examSnapshot.get('students') ?? [];
                int totalQuestionsForDate = questions.length * students.length;
                questionsCountPerDate[dateGraded] =
                    (questionsCountPerDate[dateGraded] ?? 0) +
                        totalQuestionsForDate;

                // Print the number of questions added for this date
                print(
                    'Added $totalQuestionsForDate questions for date $dateGraded');
              } catch (e) {
                print('Error processing examSnapshot: $e');
              }
            }
          }
        }
      }
    }

    // Print the final questionsCountPerDate map
    print('questionsCountPerDate: $questionsCountPerDate');

    return questionsCountPerDate;
  }

  Future<void> fetchQuestionsPerDate() async {
    Map<DateTime, int> questionsCountPerDate = await questionsPerDate();
    setState(() {
      _questionsPerDate = questionsCountPerDate;
    });
  }

  // Update the graph container part
  Widget buildGraphContainer() {
    // Create spots for the line chart
    List<DateTime> dates = _questionsPerDate.keys.toList();
    List<FlSpot> spots = [];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), _questionsPerDate[dates[i]]!.toDouble()));
    }

    // Determine the min and max values for the x-axis (indexes) and y-axis (number of questions)
    double minX = 0;
    double maxX = dates.length - 1.toDouble();
    double maxY = spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD0D5DD), // Thin border color #d0d5dd
          width: 1, // Border width 1 pixel
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exams Assigned Over Time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 232,
            color: Colors.white, // Placeholder for graph
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: spots.isNotEmpty
                    ? LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Color(0xff9b8afb),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4, // Make the spot larger
                                      color: Color(0xFF6938EF),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  }),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF6938EF).withOpacity(0.1),
                                    Color(0xFF6938EF).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          minX: minX,
                          maxX: maxX,
                          minY: 0,
                          maxY: maxY,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < dates.length) {
                                    DateTime date = dates[index];
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                          DateFormat('MM/dd').format(date)),
                                    );
                                  } else {
                                    return const SideTitleWidget(
                                        axisSide: AxisSide.bottom,
                                        child: Text(''));
                                  }
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(meta.formattedValue);
                                },
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: const Color(0xffe7e8ec),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: const Color(0xffe7e8ec),
                                strokeWidth: 1,
                              );
                            },
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
                          lineTouchData: LineTouchData(
                            enabled: true,
                            getTouchedSpotIndicator: (barData, spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: Color(0xFF6938EF),
                                    strokeWidth: 3,
                                  ),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                      radius: 8, // Make the touched spot larger
                                      color: Color(0xFF6938EF),
                                      strokeWidth: 3,
                                      strokeColor: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) =>
                                  Color.fromARGB(255, 169, 137, 255),
                              getTooltipItems:
                                  (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((barSpot) {
                                  return LineTooltipItem(
                                    '${barSpot.y}',
                                    TextStyle(color: Colors.black),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No available data yet",
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            // SizedBox(height: 20), // Add some spacing
                            SvgPicture.asset(
                              'assets/images/empty1.svg',
                              width: 100,
                              height: 100,
                            ),
                          ],
                        ),
                      )),
          ),
        ],
      ),
    );
  }

  Future<void> fetchTotalExams() async {
    if (user != null) {
      DocumentSnapshot professorSnapshot = await FirebaseFirestore.instance
          .collection('Professors')
          .doc(user!.email)
          .get();
      if (professorSnapshot.exists) {
        List<dynamic> currentExams =
            professorSnapshot.get('currentExams') ?? [];
        setState(() {
          totalExamsCreated = currentExams.length;
        });
      }
    }
  }

  Future<void> fetchTotalExamsTaken() async {
    if (user != null) {
      DocumentSnapshot professorSnapshot = await FirebaseFirestore.instance
          .collection('Professors')
          .doc(user!.email)
          .get();
      if (professorSnapshot.exists) {
        List<dynamic> currentExams =
            professorSnapshot.get('currentExams') ?? [];
        int totalTaken = 0;

        for (String examId in currentExams) {
          DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
              .collection('Exams')
              .doc(examId)
              .get();
          if (examSnapshot.exists) {
            List<dynamic> students = examSnapshot.get('students') ?? [];
            totalTaken += students.length;
          }
        }

        setState(() {
          totalExamsTaken = totalTaken;
        });
      }
    }
  }

  Future<void> fetchTotalQuestions() async {
    if (user != null) {
      DocumentSnapshot professorSnapshot = await FirebaseFirestore.instance
          .collection('Professors')
          .doc(user!.email)
          .get();
      if (professorSnapshot.exists) {
        List<dynamic> currentExams =
            professorSnapshot.get('currentExams') ?? [];

        for (String examId in currentExams) {
          DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
              .collection('Exams')
              .doc(examId)
              .get();
          if (examSnapshot.exists) {
            List<dynamic> students = examSnapshot.get('students') ?? [];
            List<dynamic> numberOfQuestions =
                examSnapshot.get('questions') ?? [];
            // Multiply the number of students by the number of questions for this exam
            totalQuestions += students.length * numberOfQuestions.length;
          }
        }

        setState(() {
          totalQuestions =
              totalQuestions; // Assuming you want to store the result here
        });
      }
    }
  }

  Future<void> fetchStudents() async {
    if (user != null) {
      DocumentSnapshot professorSnapshot = await FirebaseFirestore.instance
          .collection('Professors')
          .doc(user!.email)
          .get();
      if (professorSnapshot.exists) {
        List<dynamic> currentExams =
            professorSnapshot.get('currentExams') ?? [];

        for (String examId in currentExams) {
          DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
              .collection('Exams')
              .doc(examId)
              .get();

          if (examSnapshot.exists) {
            List<dynamic> studentsList = examSnapshot.get('students') ?? [];
            setState(() {
              students.addAll(studentsList.cast<String>());
            });
          }
        }
      }
    }
  }

  Future<void> fetchExams() async {
    if (user != null) {
      DocumentSnapshot professorSnapshot = await FirebaseFirestore.instance
          .collection('Professors')
          .doc(user!.email)
          .get();
      if (professorSnapshot.exists) {
        List<dynamic> currentExams =
            professorSnapshot.get('currentExams') ?? [];

        for (String examId in currentExams) {
          DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
              .collection('Exams')
              .doc(examId)
              .get();

          if (examSnapshot.exists) {
            setState(() {
              exams.add({
                'id': examSnapshot.id,
                ...(examSnapshot.data() as Map<String, dynamic>),
              });
            });
          }
        }
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you would like to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 3),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (selectedExamId == null) {
      mainContent = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.displayName}!',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Here\'s what\'s happening with your exams today.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateExamDetails()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.hovered)) {
                          return const Color(0xFF6938EF)
                              .withOpacity(0.8); // Slightly lighter on hover
                        }
                        return const Color(0xFF6938EF); // Default color
                      },
                    ),
                    foregroundColor: WidgetStateProperty.all(
                        Colors.white), // Button text color
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Less rounded corners
                      ),
                    ),
                  ),
                  child: const Text('+ Create new exam'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Statistic boxes and Graph container alignment
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3, // Increase space for left side
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatisticBox(
                                icon: Icons.assessment,
                                label: 'Total exams created',
                                value: '$totalExamsCreated',
                                leftMargin: 0.0,
                                rightMargin: 5.0),
                          ),
                          const SizedBox(
                              width: 8), // Spacing between statistic boxes
                          Expanded(
                            child: StatisticBox(
                                icon: Icons.today,
                                label: "Total Exams Assigned",
                                value: '$totalExamsTaken',
                                leftMargin: 5.0,
                                rightMargin: 5.0),
                          ),
                          const SizedBox(
                              width: 8), // Spacing between statistic boxes
                          Expanded(
                            child: StatisticBox(
                                icon: Icons.assignment_turned_in,
                                label: 'Total Questions Assigned',
                                value: '$totalQuestions',
                                leftMargin: 5.0,
                                rightMargin: 0.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Graph
                      buildGraphContainer(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(
                    width: 16), // Spacing between left and right content
                Expanded(
                  flex: 1, // Reduce space for right side to make it narrower
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(
                            0xFFD0D5DD), // Thin border color #d0d5dd
                        width: 1, // Border width 1 pixel
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Students',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        // Container with a fixed height
                        students.isNotEmpty
                            ? SizedBox(
                                height: 380, // Set a fixed height
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: ListView(
                                    controller:
                                        _scrollController, // Attach the ScrollController
                                    children: students
                                        .map((student) =>
                                            StudentRow(name: student))
                                        .toList(),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height:
                                    380, // Maintain the same height for consistency
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'No students yet',
                                    ),
                                    Center(
                                      child: SvgPicture.asset(
                                        'assets/images/empty2.svg',
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                onPressed: _scrollDown,
                                child: const Text('Scroll down'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Your Exams table
            Container(
              constraints: BoxConstraints(
                  minHeight: 380), // Set minimum height constraint
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFD0D5DD), // Thin border color #d0d5dd
                  width: 1, // Border width 1 pixel
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Exams',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text('Exam Name'),
                        ),
                      ), // Adjusted flex value
                      Expanded(
                          flex: 2,
                          child: Text('Course')), // Adjusted flex value
                      Expanded(
                          flex: 3,
                          child: Text('Exam ID')), // Adjusted flex value
                      Expanded(
                          flex: 2,
                          child:
                              Text('Date last graded')), // Adjusted flex value
                      Expanded(
                        flex: 2,
                        child: Center(
                          // Center the text within the Expanded widget
                          child: Text('Average score'),
                        ),
                      ), // Adjusted flex value
                      Expanded(
                        flex: 2,
                        child: Center(
                          // Center the text within the Expanded widget
                          child: Text('Grade Status'),
                        ),
                      ), // Adjusted flex value
                      SizedBox(width: 110),
                    ],
                  ),
                  const Divider(),
                  // Example rows
                  exams.length == 0
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 50), // Add some spacing
                              Text(
                                "No available exams yet",
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              // SizedBox(height: 20), // Add some spacing
                              SvgPicture.asset(
                                'assets/images/empty7.svg',
                                width: 100,
                                height: 100,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            ...exams.map((exam) => ExamRow(
                                  examName: exam['examName'] ?? 'Placeholder',
                                  examId: exam['id'] ?? 'Placeholder',
                                  course: exam['course'] ?? 'Placeholder',
                                  dateLastGraded:
                                      exam['dateLastGraded'] ?? 'No grades yet',
                                  averageScore: exam['avgScore']?.toString() ??
                                      'Placeholder',
                                  graded: exam['graded'] ?? false,
                                  onAnalyticsClick: () {
                                    setState(() {
                                      selectedExamId = exam['id'];
                                      showExamResults =
                                          true; // Set to show exam results
                                    });
                                  },
                                  onStudentGradesClick: () {
                                    setState(() {
                                      selectedExamId = exam['id'];
                                      showExamResults =
                                          false; // Set to show student grades
                                    });
                                  },
                                  onDelete: () {
                                    fetchExams(); // Call fetchExams() to refresh the exams list
                                  },
                                )),
                          ],
                        )
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    } else if (showExamResults) {
      mainContent = ExamResultsScreen(
        examId: selectedExamId!,
        onFeedbackClick: (String examId) {},
      );
    } else {
      mainContent = ExamDetailsScreen(examId: selectedExamId!);
    }

    final DateTime today = DateTime.now();
    final DateTime endDate = DateTime(2024, 12, 31);
    final int daysLeft = endDate.difference(today).inDays;

    // Calculate the progress for the year
    final DateTime startOfYear = DateTime(today.year, 1, 1);
    final DateTime endOfYear = DateTime(today.year + 1, 1, 1);
    final double progress = today.difference(startOfYear).inDays /
        endOfYear.difference(startOfYear).inDays;
    return Scaffold(
      backgroundColor: const Color(
          0xFFFCFCFD), // Set the background color of the Scaffold to #fcfcfd
      body: Row(
        children: [
          // Left menu
          Container(
            width: 250,
            color: const Color(0xFF6938EF),
            child: Column(
              children: [
                // Exam AI header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Exam AI',
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                    ],
                  ),
                ),
                if (user!.email!.endsWith('@ucdavis.edu'))
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Image.asset('assets/images/UCDavisLogo.png'),
                  ),
                if (user!.email!.endsWith('@berkeley.edu'))
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Image.asset('assets/images/UCBerkeleyLogo.png'),
                  ),
                // if (user!.email!.endsWith('@gmail.com'))
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 30),
                //   child: Image.asset('assets/images/UCBerkeleyLogo.png'),
                // ),
                const SizedBox(height: 20),
                // Menu items
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedExamId = null;
                    });
                  },
                  child: MenuButton(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    color: Colors.white,
                  ),
                ),
                const MenuButton(
                    icon: Icons.assignment, label: 'Exams', color: Colors.grey),
                const MenuButton(
                    icon: Icons.people, label: 'Students', color: Colors.grey),
                const MenuButton(
                    icon: Icons.class_, label: 'Classes', color: Colors.grey),
                const MenuButton(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    color: Colors.grey),
                const MenuButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Colors.grey),
                const Spacer(),
                // Usage card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80, // Adjust the size as needed
                              height: 80, // Adjust the size as needed
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth:
                                    8, // Adjust the stroke width as needed
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6938EF)),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$daysLeft', // Display the number of days left
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'days', // Display the text "days left"
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text('ExamAI Access',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            'ExamAI is free to use until December 31st, 2024.'),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                // Profile image and name from Google Sign-In
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        backgroundColor: user?.photoURL == null
                            ? const Color(0xFF6938EF)
                            : Colors.transparent,
                        child: user?.photoURL == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName != null &&
                                      user!.displayName!.length > 17
                                  ? user!.displayName!.substring(0, 17)
                                  : user?.displayName ?? 'No Name',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Text(
                              'Professor',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.exit_to_app, color: Colors.white),
                        onPressed: _showSignOutDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: mainContent,
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final String examId;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog(
      {required this.examId, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        children: [
          Icon(MdiIcons.alertCircleOutline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          const Text(
            'Are you sure you want to delete this exam?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Deletions are irreversible. Students will lose access\nto the exam and results if applicable.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16), // Increased space
        ElevatedButton(
          onPressed: () async {
            await _deleteExam(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Confirm',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteExam(BuildContext context) async {
    try {
      DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
          .collection('Exams')
          .doc(examId)
          .get();

      List<String> students = List<String>.from(examSnapshot['students']);

      // Remove examId from each student's currentExams and completedExams
      for (String studentEmail in students) {
        DocumentReference studentRef =
            FirebaseFirestore.instance.collection('Students').doc(studentEmail);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          try {
            DocumentSnapshot snapshot = await transaction.get(studentRef);

            if (snapshot.exists) {
              List<dynamic> currentExams = snapshot.get('currentExams') ?? [];
              Map<String, dynamic> completedExams = {};
              if ((snapshot.data() as Map<String, dynamic>)
                  .containsKey('completedExams')) {
                completedExams = snapshot.get('completedExams') ?? {};
              }

              currentExams.remove(examId);
              completedExams.remove(examId);

              transaction.update(studentRef, {
                'currentExams': currentExams,
                if ((snapshot.data() as Map<String, dynamic>)
                    .containsKey('completedExams'))
                  'completedExams': completedExams,
              });
            }
          } catch (e) {
            print('Error processing student $studentEmail: $e');
          }
        });
      }

      // Remove examId from professor's currentExams
      String? professorEmail = FirebaseAuth.instance.currentUser?.email;
      if (professorEmail != null) {
        DocumentReference professorRef = FirebaseFirestore.instance
            .collection('Professors')
            .doc(professorEmail);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          try {
            DocumentSnapshot snapshot = await transaction.get(professorRef);

            if (snapshot.exists) {
              List<dynamic> currentExams = snapshot.get('currentExams') ?? [];

              currentExams.remove(examId);

              transaction.update(professorRef, {'currentExams': currentExams});
            }
          } catch (e) {
            print('Error processing professor $professorEmail: $e');
          }
        });
      }

      // Finally, delete the exam document
      await FirebaseFirestore.instance.collection('Exams').doc(examId).delete();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exam deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to ProfessorScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ProfessorScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error during deletion process: $e');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete exam. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color; // Add a color parameter

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    this.color = Colors.grey, // Default color is grey if not specified
  });

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const hoverColor =
        Color(0xFF7A56FF); // A bit lighter purple for hover state

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered
            ? hoverColor
            : Colors.transparent, // Keep the container transparent
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.color), // Use the passed color
            const SizedBox(width: 16),
            Text(widget.label,
                style: TextStyle(color: widget.color)), // Use the passed color
          ],
        ),
      ),
    );
  }
}

class StatisticBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double leftMargin;
  final double rightMargin;

  const StatisticBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.leftMargin = 0.0, // Default left margin
    this.rightMargin = 0.0, // Default right margin
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150, // Fixed height for better layout consistency
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD0D5DD), // Thin border color #d0d5dd
            width: 1, // Border width 1 pixel
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color.fromARGB(255, 137, 68, 255), size: 40),
                SizedBox(width: 8), // Add a SizedBox for spacing
                Flexible(
                  child: Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.clip, // Ensure text wraps
                      textAlign:
                          TextAlign.left), // TextAlign.left for start alignment
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 8), // SizedBox for spacing before the text
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class StudentRow extends StatelessWidget {
  final String name;

  const StudentRow({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF6938EF),
            child: Icon(Icons.person,
                color: Colors.white), // Updated to preferred color
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(name, overflow: TextOverflow.clip),
          )
        ],
      ),
    );
  }
}

class ExamRow extends StatefulWidget {
  final String examName;
  final String examId;
  final String course;
  final String dateLastGraded;
  final String averageScore;
  final bool graded;
  final VoidCallback onAnalyticsClick;
  final VoidCallback onStudentGradesClick;
  final VoidCallback onDelete; // Add the onDelete callback

  const ExamRow({
    super.key,
    required this.examName,
    required this.examId,
    required this.course,
    required this.dateLastGraded,
    required this.averageScore,
    required this.graded,
    required this.onAnalyticsClick,
    required this.onStudentGradesClick,
    required this.onDelete, // Add the onDelete parameter
  });

  @override
  _ExamRowState createState() => _ExamRowState();
}

class _ExamRowState extends State<ExamRow> {
  bool _isHovered = false;

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

  @override
  Widget build(BuildContext context) {
    double score =
        double.tryParse(widget.averageScore.replaceAll('%', '')) ?? 0;
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Keep the existing onRowClick functionality if needed
        },
        child: Container(
          color: _isHovered
              ? Colors.grey[200]
              : Colors.white, // Slight gray when hovered, white otherwise
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    widget.examName,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ), // Adjusted flex value
              Expanded(
                  flex: 2, child: Text(widget.course)), // Adjusted flex value
              Expanded(
                  flex: 3, child: Text(widget.examId)), // Adjusted flex value
              Expanded(
                  flex: 2,
                  child: Text(widget.dateLastGraded)), // Adjusted flex value
              Expanded(
                flex: 2, // Adjusted flex value
                child: Center(
                  // Center the content within the Expanded widget
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6938EF)),
                          strokeWidth: 5,
                        ),
                      ),
                      Text('${score.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2, // Adjusted flex value
                child: Center(
                  // Center the content within the Expanded widget
                  child: widget.graded
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 114, 211, 255),
                                    const Color.fromARGB(255, 236, 131, 255),
                                    Color.fromARGB(255, 255, 99, 60)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ElevatedButton(
                                onPressed: widget.onAnalyticsClick,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0)),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                                  shadowColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                                child: Text(
                                  'Analytics',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 20), // Add this line
                            ElevatedButton(
                              onPressed: widget.onStudentGradesClick,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6938EF),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Student\nGrades',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Column(
                                  children: [
                                    const Text('Start Grading'),
                                    const SizedBox(height: 10),
                                    Image.asset(
                                      'assets/images/aiGrade.png',
                                      height: 200.0, // Set the image height
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  'The AI will start grading after you click "Submit". \nEnsure all students have submitted their exams to avoid early feedback.',
                                  textAlign: TextAlign.center, // Center align
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Submit'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      triggerGrading(widget.examId);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Grade Exam',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
              // Assuming ButtonBar does not need flex as it contains fixed-size buttons
              SizedBox(
                width: 110,
                child: ButtonBar(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateExamDetails(
                              examId: widget.examId,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeleteConfirmationDialog(
                              examId: widget.examId,
                              onDelete: widget.onDelete,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
