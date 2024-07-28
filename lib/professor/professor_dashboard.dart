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
// import 'dart:math' as math;
import 'colors_professor.dart';
import 'package:flutter_switch/flutter_switch.dart';

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
  String colorToggle = "light";

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
        color: colorToggle == "light"
            ? AppColorsLight.pure_white
            : AppColorsDark.pure_white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorToggle == "light"
              ? AppColorsLight.light_grey
              : AppColorsDark.light_grey, // Thin border color #d0d5dd
          width: 1, // Border width 1 pixel
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions Graded Over Time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 232,
            color: colorToggle == "light"
                ? AppColorsLight.pure_white
                : AppColorsDark.pure_white, // Placeholder for graph
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: spots.isNotEmpty
                    ? LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: colorToggle == "light"
                                  ? AppColorsLight.main_purple_light
                                  : AppColorsDark.main_purple_light,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4, // Make the spot larger
                                      color: colorToggle == "light"
                                          ? AppColorsLight.main_purple
                                          : AppColorsDark.main_purple,
                                      strokeWidth: 2,
                                      strokeColor: colorToggle == "light"
                                          ? AppColorsLight.pure_white
                                          : AppColorsDark.pure_white,
                                    );
                                  }),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    colorToggle == "light"
                                        ? AppColorsLight.chart_gradientStart
                                        : Color.fromARGB(201, 153, 255, 0),
                                    colorToggle == "light"
                                        ? AppColorsLight.chart_gradientEnd
                                        : AppColorsDark.chart_gradientEnd,
                                    colorToggle == "light"
                                        ? Color.fromARGB(0, 255, 255, 255)
                                        : Color.fromARGB(0, 0, 0, 0),
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
                                  // Ensure index is within the range of dates list
                                  if (index >= 0 && index < dates.length) {
                                    DateTime date = dates[index];
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child:
                                          Text(DateFormat('MM/dd').format(date),
                                              style: TextStyle(
                                                color: colorToggle == "light"
                                                    ? AppColorsLight.black
                                                    : AppColorsDark.black,
                                              )),
                                    );
                                  } else {
                                    return SideTitleWidget(
                                      axisSide: AxisSide.bottom,
                                      child: Text('',
                                          style: TextStyle(
                                            color: colorToggle == "light"
                                                ? AppColorsLight.black
                                                : AppColorsDark.black,
                                          )),
                                    );
                                  }
                                },
                                reservedSize: 30,
                                interval:
                                    1, // Show labels only at the points with data
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(meta.formattedValue,
                                      style: TextStyle(
                                        color: colorToggle == "light"
                                            ? AppColorsLight.black
                                            : AppColorsDark.black,
                                      ));
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
                                color: colorToggle == "light"
                                    ? AppColorsLight.light_grey
                                    : AppColorsDark.light_grey,
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: colorToggle == "light"
                                    ? AppColorsLight.light_grey
                                    : AppColorsDark.light_grey,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.light_grey
                                      : AppColorsDark.light_grey),
                              left: BorderSide(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.light_grey
                                      : AppColorsDark.light_grey),
                              right: BorderSide(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.light_grey
                                      : AppColorsDark.light_grey),
                              top: BorderSide(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.light_grey
                                      : AppColorsDark.light_grey),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            getTouchedSpotIndicator: (barData, spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: colorToggle == "light"
                                        ? AppColorsLight.main_purple
                                        : AppColorsDark.main_purple,
                                    strokeWidth: 3,
                                  ),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                      radius: 8, // Make the touched spot larger
                                      color: colorToggle == "light"
                                          ? AppColorsLight.main_purple
                                          : AppColorsDark.main_purple,
                                      strokeWidth: 3,
                                      strokeColor: colorToggle == "light"
                                          ? AppColorsLight.pure_white
                                          : AppColorsDark.pure_white,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => colorToggle == "light"
                                  ? AppColorsLight.main_purple_light
                                  : AppColorsDark.main_purple_light,
                              getTooltipItems:
                                  (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((barSpot) {
                                  return LineTooltipItem(
                                    '${barSpot.y}',
                                    TextStyle(
                                      color: colorToggle == "light"
                                          ? AppColorsLight.pure_white
                                          : AppColorsDark.pure_white,
                                    ),
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
                                fontSize: 16,
                                color: colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.black,
                              ),
                            ),
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
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black),
                    ),
                    Text(
                      'Here\'s what\'s happening with your exams today.',
                      style: TextStyle(
                          fontSize: 16,
                          color: colorToggle == "light"
                              ? AppColorsLight.dark_grey
                              : AppColorsDark.dark_grey),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateExamDetails(
                                colorToggle: colorToggle,
                              )),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return colorToggle == "light"
                              ? AppColorsLight.main_purple_light
                              : AppColorsDark
                                  .main_purple_light; // Slightly lighter on hover
                        }
                        return colorToggle == "light"
                            ? AppColorsLight.main_purple
                            : AppColorsDark.main_purple; // Default color
                      },
                    ),
                    foregroundColor: MaterialStateProperty.all(
                        colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.pure_white), // Button text color
                    shape: MaterialStateProperty.all(
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
                                rightMargin: 5.0,
                                colorToggle: colorToggle),
                          ),
                          const SizedBox(
                              width: 8), // Spacing between statistic boxes
                          Expanded(
                            child: StatisticBox(
                                icon: Icons.today,
                                label: "Total Exams Assigned",
                                value: '$totalExamsTaken',
                                leftMargin: 5.0,
                                rightMargin: 5.0,
                                colorToggle: colorToggle),
                          ),
                          const SizedBox(
                              width: 8), // Spacing between statistic boxes
                          Expanded(
                            child: StatisticBox(
                                icon: Icons.assignment_turned_in,
                                label: 'Total Questions Assigned',
                                value: '$totalQuestions',
                                leftMargin: 5.0,
                                rightMargin: 0.0,
                                colorToggle: colorToggle),
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
                      color: colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.card_background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorToggle == "light"
                            ? AppColorsLight.light_grey
                            : AppColorsDark
                                .light_grey, // Thin border color #d0d5dd
                        width: 1, // Border width 1 pixel
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Students',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.black)),
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
                                        .map((student) => StudentRow(
                                            name: student,
                                            colorToggle: colorToggle))
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
                                    Text(
                                      'No students yet',
                                      style: TextStyle(
                                          color: colorToggle == "light"
                                              ? AppColorsLight.black
                                              : AppColorsDark.black),
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
                                child: Text('Scroll down',
                                    style: TextStyle(
                                        color: colorToggle == "light"
                                            ? AppColorsLight.black
                                            : AppColorsDark.black)),
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
                color: colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.pure_white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorToggle == "light"
                      ? AppColorsLight.light_grey
                      : AppColorsDark.light_grey, // Thin border color #d0d5dd
                  width: 1, // Border width 1 pixel
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Exams',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text('Exam Name',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark.black)),
                        ),
                      ), // Adjusted flex value
                      Expanded(
                          flex: 2,
                          child: Text('Course',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark
                                          .black))), // Adjusted flex value
                      Expanded(
                          flex: 3,
                          child: Text('Exam ID',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark
                                          .black))), // Adjusted flex value
                      Expanded(
                          flex: 2,
                          child: Text('Date last graded',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark
                                          .black))), // Adjusted flex value
                      Expanded(
                        flex: 2,
                        child: Center(
                          // Center the text within the Expanded widget
                          child: Text('Average score',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark.black)),
                        ),
                      ), // Adjusted flex value
                      Expanded(
                        flex: 2,
                        child: Center(
                          // Center the text within the Expanded widget
                          child: Text('Grade Status',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark.black)),
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
                                  fontSize: 16,
                                  color: colorToggle == "light"
                                      ? AppColorsLight.black
                                      : AppColorsDark.black,
                                ),
                              ),
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
                                  averageScore:
                                      exam['avgScore']?.toString() ?? '0/10',
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
                                  colorToggle: colorToggle,
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
        colorToggle: colorToggle,
        examId: selectedExamId!,
        onFeedbackClick: (String examId) {},
      );
    } else {
      mainContent = ExamDetailsScreen(
        examId: selectedExamId!,
        colorToggle: colorToggle,
      );
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
      backgroundColor: colorToggle == "light"
          ? AppColorsLight.pure_white
          : AppColorsDark
              .pure_white, // Set the background color of the Scaffold
      body: Row(
        children: [
          // Left menu
          Container(
            width: 250,
            color: colorToggle == "light"
                ? AppColorsLight.main_purple
                : AppColorsDark.leftMenu_background,
            child: Column(
              children: [
                // Exam AI header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Add this line
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school,
                              color: colorToggle == "light"
                                  ? AppColorsLight.pure_white
                                  : AppColorsDark.main_purple),
                          SizedBox(width: 8),
                          Text(' Exam AI',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.pure_white
                                      : AppColorsDark.black,
                                  fontSize: 24)),
                        ],
                      ),
                      Transform.scale(
                        scale: 0.65, // Adjust the scale factor as needed
                        child: FlutterSwitch(
                          value: colorToggle == "light",
                          onToggle: (bool value) {
                            setState(() {
                              colorToggle = value ? "light" : "dark";
                            });
                          },
                          activeColor: AppColorsLight.pure_white,
                          inactiveColor: AppColorsDark.card_background,
                          activeToggleColor:
                              Colors.black, // Active circle color
                          inactiveToggleColor:
                              Colors.white, // Inactive circle color
                          activeIcon: Icon(
                            Icons.nightlight_round, // Moon icon
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          inactiveIcon: Icon(
                            Icons.wb_sunny, // Sun icon
                            color: Color.fromARGB(255, 255, 183, 0),
                          ),
                        ),
                      )
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
                    colorToggle: colorToggle,
                    enabled: true,
                    isSelected: selectedExamId == null,
                  ),
                ),
                MenuButton(
                    icon: Icons.assignment,
                    label: 'Exams',
                    enabled: false,
                    colorToggle: colorToggle,
                    isSelected: selectedExamId != null),
                MenuButton(
                    icon: Icons.people,
                    label: 'Students',
                    enabled: false,
                    colorToggle: colorToggle,
                    isSelected: selectedExamId != null),
                MenuButton(
                    icon: Icons.class_,
                    label: 'Classes',
                    enabled: false,
                    colorToggle: colorToggle,
                    isSelected: selectedExamId != null),
                MenuButton(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    enabled: false,
                    colorToggle: colorToggle,
                    isSelected: selectedExamId != null),
                MenuButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    enabled: false,
                    colorToggle: colorToggle,
                    isSelected: selectedExamId != null),
                const Spacer(),
                // Usage card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.main_purple,
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
                                backgroundColor: colorToggle == "light"
                                    ? AppColorsLight.light_grey
                                    : AppColorsDark.light_grey,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorToggle == "light"
                                        ? AppColorsLight.main_purple
                                        : AppColorsDark.main_purple),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$daysLeft', // Display the number of days left
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.pure_white,
                                  ),
                                ),
                                Text(
                                  'days', // Display the text "days left"
                                  style: TextStyle(
                                    color: colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.pure_white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text('ExamAI Access',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.pure_white)),
                        Text('ExamAI is free to use until December 31st, 2024.',
                            style: TextStyle(
                                color: colorToggle == "light"
                                    ? AppColorsLight.dark_grey
                                    : AppColorsDark.light_grey)),
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
                            ? colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.black
                            : Colors.transparent,
                        child: user?.photoURL == null
                            ? Icon(
                                Icons.person,
                                color: colorToggle == "light"
                                    ? AppColorsLight.pure_white
                                    : AppColorsDark.black,
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
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.pure_white
                                      : AppColorsDark.black),
                            ),
                            Text(
                              'Professor',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.light_grey
                                      : AppColorsDark.dark_grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.exit_to_app,
                            color: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.pure_white),
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
  final String colorToggle; // Add a color parameter

  const DeleteConfirmationDialog({
    required this.examId,
    required this.onDelete,
    required this.colorToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: colorToggle == "light"
          ? AppColorsLight.pure_white
          : AppColorsDark.pure_white,
      title: Column(
        children: [
          Icon(MdiIcons.alertCircleOutline,
              color: colorToggle == "light"
                  ? AppColorsLight.red
                  : AppColorsDark.red,
              size: 50),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to delete this exam?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deletions are irreversible. Students will lose access\nto the exam and results if applicable.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.dark_grey
                  : AppColorsDark.dark_grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: colorToggle == "light"
                ? AppColorsLight.black
                : AppColorsDark.black,
            backgroundColor: colorToggle == "light"
                ? AppColorsLight.pure_white
                : AppColorsDark.pure_white,
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
            backgroundColor:
                colorToggle == "light" ? AppColorsLight.red : AppColorsDark.red,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Confirm',
            style: TextStyle(
              color: colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark.pure_white,
            ),
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
          backgroundColor: colorToggle == "light"
              ? AppColorsLight.green
              : AppColorsDark.green,
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
          backgroundColor:
              colorToggle == "light" ? AppColorsLight.red : AppColorsDark.red,
        ),
      );
    }
  }
}

class MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String colorToggle; // Color parameter
  final bool isSelected; // Selection state parameter
  final bool enabled; // Enabled state parameter

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.colorToggle,
    this.isSelected = false, // Default to false if not specified
    this.enabled = true, // Default to true if not specified
  });

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = widget.colorToggle == "light"
        ? AppColorsLight.main_purple_light
        : AppColorsDark.main_purple_light;
    final iconColor = widget.enabled
        ? AppColorsLight.pure_white
        : AppColorsLight.disabled_grey;
    final textColor = widget.enabled
        ? AppColorsLight.pure_white
        : AppColorsLight.disabled_grey;
    final selectedColor = widget.colorToggle == "light"
        ? AppColorsLight.main_purple_dark
        : AppColorsDark.main_purple_dark;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: Container(
        color: widget.isSelected
            ? selectedColor
            : (_isHovered ? hoverColor : Colors.transparent),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            Icon(widget.icon, color: iconColor),
            const SizedBox(width: 16),
            Text(widget.label, style: TextStyle(color: textColor)),
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
  final String colorToggle;

  const StatisticBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.colorToggle,
    this.leftMargin = 0.0, // Default left margin
    this.rightMargin = 0.0, // Default right margin
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        colorToggle == "light" ? AppColorsLight.black : AppColorsDark.black;
    final iconColor = colorToggle == "light"
        ? AppColorsLight.main_purple
        : AppColorsDark.main_purple;
    final containerColor = colorToggle == "light"
        ? AppColorsLight.pure_white
        : AppColorsDark.card_background;
    final borderColor = colorToggle == "light"
        ? AppColorsLight.light_grey
        : AppColorsDark.light_grey;

    return Expanded(
      child: Container(
        height: 150, // Fixed height for better layout consistency
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor, // Thin border color #d0d5dd
            width: 1, // Border width 1 pixel
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 40),
                SizedBox(width: 8), // Add a SizedBox for spacing
                Flexible(
                  child: Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor),
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
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: textColor),
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
  final String colorToggle;

  const StudentRow({super.key, required this.name, required this.colorToggle});

  @override
  Widget build(BuildContext context) {
    final textColor =
        colorToggle == "light" ? AppColorsLight.black : AppColorsDark.black;
    final iconColor = colorToggle == "light"
        ? AppColorsLight.main_purple
        : AppColorsDark.main_purple;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor,
            child: Icon(Icons.person,
                color: colorToggle == "light"
                    ? AppColorsLight.pure_white
                    : AppColorsDark.pure_white),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(name,
                overflow: TextOverflow.clip,
                style: TextStyle(color: textColor)),
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
  final String colorToggle;

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
    required this.colorToggle,
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
    List<String> scoreParts = widget.averageScore.split('/');
    double score = double.tryParse(scoreParts[0]) ?? 0;
    double maxScore = double.tryParse(scoreParts[1]) ?? 100;
    double percentage = (score / maxScore) * 100;
    final textColor = widget.colorToggle == "light"
        ? AppColorsLight.black
        : AppColorsDark.black;
    final progressColor = widget.colorToggle == "light"
        ? AppColorsLight.main_purple
        : AppColorsDark.main_purple;
    final buttonBackgroundColor = widget.colorToggle == "light"
        ? AppColorsLight.main_purple
        : AppColorsDark.main_purple;
    final buttonTextColor = widget.colorToggle == "light"
        ? AppColorsLight.light_grey
        : AppColorsDark.light_grey;
    final redColor =
        widget.colorToggle == "light" ? AppColorsLight.red : AppColorsDark.red;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Keep the existing onRowClick functionality if needed
        },
        child: Container(
          color: _isHovered
              ? widget.colorToggle == "light"
                  ? AppColorsLight.light_grey
                  : AppColorsDark.light_grey
              : widget.colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark
                      .pure_white, // Slight gray when hovered, white otherwise
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    widget.examName,
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: textColor),
                  ),
                ),
              ), // Adjusted flex value
              Expanded(
                  flex: 2,
                  child: Text(widget.course,
                      style:
                          TextStyle(color: textColor))), // Adjusted flex value
              Expanded(
                  flex: 3,
                  child: Text(widget.examId,
                      style:
                          TextStyle(color: textColor))), // Adjusted flex value
              Expanded(
                  flex: 2,
                  child: Text(widget.dateLastGraded,
                      style:
                          TextStyle(color: textColor))), // Adjusted flex value
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
                          value: percentage / 100,
                          backgroundColor: widget.colorToggle == "light"
                              ? AppColorsLight.light_grey
                              : AppColorsDark.light_grey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                          strokeWidth: 5,
                        ),
                      ),
                      Text('${score.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 10, color: textColor)),
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
                                    ),
                                  ),
                                  shadowColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                                child: Text(
                                  'Analytics',
                                  style: TextStyle(color: buttonTextColor),
                                ),
                              ),
                            ),
                            SizedBox(width: 20), // Add this line
                            ElevatedButton(
                              onPressed: widget.onStudentGradesClick,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonBackgroundColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Student\nGrades',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: buttonTextColor),
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
                                      Navigator.of(context)
                                          .pop(); // Close the current dialog
                                      triggerGrading(widget
                                          .examId); // Trigger grading process
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'You\'re ready to go!'),
                                            content: const Text(
                                              'Come back in a couple of minutes and refresh the page for results!',
                                              textAlign: TextAlign.center,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.colorToggle == "light"
                                ? AppColorsLight.green
                                : AppColorsDark.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Grade Exam',
                            style: TextStyle(color: buttonTextColor),
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
                      icon: Icon(
                        Icons.edit,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.dark_grey
                            : AppColorsDark.dark_grey,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateExamDetails(
                              colorToggle: widget.colorToggle,
                              examId: widget.examId,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: redColor,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeleteConfirmationDialog(
                              examId: widget.examId,
                              onDelete: widget.onDelete,
                              colorToggle: widget.colorToggle,
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
