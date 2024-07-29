import 'package:examai_flutter/main.dart';
import 'package:examai_flutter/student/studentExam_feedback.dart';
import 'package:examai_flutter/student/takeExam_examSelection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import '../professor/colors_professor.dart';
import 'examResults.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StudentScreen(),
    );
  }
}

class StudentScreen extends StatefulWidget {
  final String? colorToggle;

  StudentScreen({this.colorToggle});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  User? user;
  List<Map<String, dynamic>> recentExams = [];
  List<Map<String, dynamic>> upcomingExams = [];
  String? selectedExamId;
  String? feedbackExamId;
  double averageScore = 0.0;
  late String colorToggle;

  @override
  void initState() {
    super.initState();
    colorToggle = widget.colorToggle ?? "light";
    fetchUser();
  }

  Future<void> fetchUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      user = currentUser;
    });
    if (user != null) {
      await fetchRecentExams(user!.email!);
      await fetchUpcomingExams(user!.email!);
    }
  }

  Future<void> fetchRecentExams(String email) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('Students')
        .doc(email)
        .get();

    if (studentDoc.exists) {
      final completedExams =
          studentDoc.data()?['completedExams'] as Map<String, dynamic>? ?? {};

      double totalScore = 0.0;
      double totalMaxScore = 0.0;
      int examCount = 0;

      for (var examId in completedExams.keys) {
        final examSnapshot = await FirebaseFirestore.instance
            .collection('Exams')
            .doc(examId)
            .get();

        if (examSnapshot.exists) {
          final examDetails = examSnapshot.data()!;

          final gradedSnapshot = await FirebaseFirestore.instance
              .collection('Exams')
              .doc(examId)
              .collection('graded')
              .doc(email)
              .get();

          if (gradedSnapshot.exists && gradedSnapshot.data() != null) {
            final gradedData = gradedSnapshot.data()!;
            final finalGrade = gradedData['final_grade'] ?? '0/0';
            List<String> scoreParts = finalGrade.split('/');
            double score = double.tryParse(scoreParts[0]) ?? 0;
            double maxScore = double.tryParse(scoreParts[1]) ?? 1;

            totalScore += score;
            totalMaxScore += maxScore;
            examCount++;

            recentExams.add({
              'examName': examDetails['examName'] ?? 'Placeholder',
              'examId': examId,
              'date': examDetails['date'] ?? 'Placeholder',
              'time': examDetails['time'] ?? 'Placeholder',
              'students': List<String>.from(examDetails['students'] ?? []),
              'score': finalGrade,
            });
          }
        }
      }

      if (examCount > 0) {
        averageScore = (totalScore / totalMaxScore) * 100;
      }

      setState(() {});
    }
  }

  Future<void> fetchUpcomingExams(String email) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('Students')
        .doc(email)
        .get();

    if (studentDoc.exists) {
      final currentExams =
          List<String>.from(studentDoc.data()?['currentExams'] ?? []);

      for (var examId in currentExams) {
        final examSnapshot = await FirebaseFirestore.instance
            .collection('Exams')
            .doc(examId)
            .get();

        if (examSnapshot.exists) {
          final examDetails = examSnapshot.data()!;
          final students = List<String>.from(examDetails['students'] ?? []);

          if (students.contains(email)) {
            final date = examDetails['date'] ?? 'Placeholder';
            final time = examDetails['time'] ?? 'Placeholder';

            String formattedDateTime = 'Placeholder';
            try {
              final dateTimeString = '$date $time';
              final dateTime =
                  DateFormat('yyyy-MM-dd hh:mm a').parse(dateTimeString);
              formattedDateTime =
                  DateFormat('E, MMM d \'@\' h:mma').format(dateTime);
            } catch (e) {}

            upcomingExams.add({
              'examId': examId,
              'examName': examDetails['examName'] ?? 'Placeholder',
              'description': examDetails['course'] ?? 'Upcoming Exam',
              'formattedDateTime': formattedDateTime,
            });
          }
        }
      }

      setState(() {});
    }
  }

  void onExamRowClick(String examId) {
    setState(() {
      selectedExamId = examId;
      feedbackExamId = null;
    });
  }

  void onFeedbackClick(String examId) {
    setState(() {
      feedbackExamId = examId;
    });
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
        backgroundColor: colorToggle == "light"
            ? AppColorsLight.pure_white
            : AppColorsDark.pure_white,
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: colorToggle == "light"
                ? AppColorsLight.black
                : AppColorsDark.black,
          ),
        ),
        content: Text(
          'Are you sure you would like to sign out?',
          style: TextStyle(
            color: colorToggle == "light"
                ? AppColorsLight.black
                : AppColorsDark.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorToggle == "light"
                    ? AppColorsLight.main_purple
                    : AppColorsDark.main_purple,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            child: Text(
              'Yes',
              style: TextStyle(
                color: colorToggle == "light"
                    ? AppColorsLight.main_purple
                    : AppColorsDark.main_purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (selectedExamId == null) {
      mainContent = SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              alignment: Alignment
                  .centerLeft, // Ensure the container aligns its content to the start
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.displayName}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
                  Text(
                    'Here\'s what\'s happening with your exams today.',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorToggle == "light"
                          ? AppColorsLight.dark_grey
                          : AppColorsDark.dark_grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 220,
              child: Row(
                children: [
                  Container(
                    height: 220,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            StatisticBox(
                              iconPath: 'assets/images/empty1.svg',
                              label: 'Exam 1',
                              value: 'Not graded',
                              topMargin: 0,
                              bottomMargin: 10,
                              leftMargin: 0,
                              rightMargin: 10,
                              colorToggle: colorToggle,
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty2.svg',
                              label: 'Homework 1',
                              value: 'Not graded',
                              topMargin: 0,
                              bottomMargin: 10,
                              leftMargin: 10,
                              rightMargin: 10,
                              colorToggle: colorToggle,
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty3.svg',
                              label: 'Quiz 1',
                              value: 'Not graded',
                              topMargin: 0,
                              bottomMargin: 10,
                              leftMargin: 10,
                              rightMargin: 0,
                              colorToggle: colorToggle,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            StatisticBox(
                              iconPath: 'assets/images/empty4.svg',
                              label: 'Exam 2',
                              value: 'Not graded',
                              topMargin: 10,
                              bottomMargin: 0,
                              leftMargin: 0,
                              rightMargin: 10,
                              colorToggle: colorToggle,
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty5.svg',
                              label: 'Homework 2',
                              value: 'Not graded',
                              topMargin: 10,
                              bottomMargin: 0,
                              leftMargin: 10,
                              rightMargin: 10,
                              colorToggle: colorToggle,
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty6.svg',
                              label: 'Quiz 2',
                              value: 'Not graded',
                              topMargin: 10,
                              bottomMargin: 0,
                              leftMargin: 10,
                              rightMargin: 0,
                              colorToggle: colorToggle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 240,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.card_background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colorToggle == "light"
                              ? AppColorsLight.light_grey
                              : AppColorsDark.pure_white,
                          width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Overall Performance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: CircularProgressIndicator(
                                    value: averageScore / 100,
                                    backgroundColor: colorToggle == "light"
                                        ? AppColorsLight.light_grey
                                        : AppColorsDark.light_grey,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorToggle == "light"
                                          ? AppColorsLight.main_purple
                                          : AppColorsDark.main_purple,
                                    ),
                                    strokeWidth: 10,
                                  ),
                                ),
                                Text(
                                  '${averageScore.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 270,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colorToggle == "light"
                              ? AppColorsLight.light_grey
                              : AppColorsDark.light_grey,
                          width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Exam',
                          style: TextStyle(
                            color: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.pure_white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '11:24 AM',
                          style: TextStyle(
                            color: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.pure_white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Biology',
                          style: TextStyle(
                            color: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.pure_white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'The human body',
                          style: TextStyle(
                            color: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.pure_white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '12 : 24 : 00 PM',
                          style: TextStyle(
                            color: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.pure_white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height - 350,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.pure_white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: colorToggle == "light"
                                ? AppColorsLight.light_grey
                                : AppColorsDark.light_grey,
                            width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent exams',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    'Exam Name',
                                    style: TextStyle(
                                      color: colorToggle == "light"
                                          ? AppColorsLight.black
                                          : AppColorsDark.black,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Date',
                                  style: TextStyle(
                                    color: colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Time',
                                  style: TextStyle(
                                    color: colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Students',
                                  style: TextStyle(
                                    color: colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Score',
                                  style: TextStyle(
                                    color: colorToggle == "light"
                                        ? AppColorsLight.black
                                        : AppColorsDark.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          recentExams.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 50),
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
                                    Divider(),
                                    ...recentExams.map((exam) => ExamRow(
                                          examName: exam['examName'],
                                          examId: exam['examId'],
                                          date: exam['date'],
                                          time: exam['time'],
                                          students: exam['students'],
                                          score: exam['score'],
                                          onRowClick: onExamRowClick,
                                          colorToggle: colorToggle,
                                        )),
                                  ],
                                )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 400,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.pure_white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: colorToggle == "light"
                                ? AppColorsLight.light_grey
                                : AppColorsDark.light_grey,
                            width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upcoming exams',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: upcomingExams.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 50.0),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'No upcoming exams yet...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: colorToggle == "light"
                                                  ? AppColorsLight.black
                                                  : AppColorsDark.black,
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  20), // Add some space between the text and the image
                                          SvgPicture.asset(
                                            'assets/images/empty8.svg', // Replace with your SVG image path
                                            width: 100,
                                            height: 100,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: upcomingExams.length,
                                    itemBuilder: (context, index) {
                                      final exam = upcomingExams[index];
                                      return ExamRowSimple(
                                        examName:
                                            exam['examName'] ?? 'Placeholder',
                                        description: exam['description'] ??
                                            'Placeholder',
                                        formattedDateTime:
                                            exam['formattedDateTime'] ??
                                                'Placeholder',
                                        icon: Icons.calendar_today,
                                        colorToggle: colorToggle,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (feedbackExamId != null) {
      mainContent = StudentExamFeedbackScreen(
          examId: feedbackExamId!, colorToggle: colorToggle);
    } else {
      mainContent = ExamResultsScreen(
        examId: selectedExamId!,
        onFeedbackClick: onFeedbackClick,
        colorToggle: colorToggle,
      );
    }

    // Calculate the number of days from today until December 31, 2024
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
          ? AppColorsLight.lightest_grey
          : AppColorsDark.pure_white,
      body: Row(
        children: [
          Container(
            width: 250,
            color: colorToggle == "light"
                ? AppColorsLight.main_purple
                : AppColorsDark.leftMenu_background,
            child: Column(
              children: [
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
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            StudentScreen(colorToggle: colorToggle),
                        transitionDuration: Duration(seconds: 0),
                        reverseTransitionDuration: Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: Tween<double>(begin: 1.0, end: 1.0)
                                .animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: MenuButton(
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      color: colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.black,
                      colorToggle: colorToggle),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentPortalScreen(
                                colorToggle: colorToggle,
                              )),
                    );
                  },
                  child: MenuButton(
                      icon: Icons.assignment,
                      label: 'Exams',
                      color: colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.black,
                      colorToggle: colorToggle),
                ),
                MenuButton(
                    icon: Icons.people,
                    label: 'Students',
                    color: colorToggle == "light"
                        ? AppColorsLight.disabled_grey
                        : AppColorsDark.disabled_grey,
                    colorToggle: colorToggle),
                MenuButton(
                    icon: Icons.class_,
                    label: 'Classes',
                    color: colorToggle == "light"
                        ? AppColorsLight.disabled_grey
                        : AppColorsDark.disabled_grey,
                    colorToggle: colorToggle),
                MenuButton(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    color: colorToggle == "light"
                        ? AppColorsLight.disabled_grey
                        : AppColorsDark.disabled_grey,
                    colorToggle: colorToggle),

                MenuButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: colorToggle == "light"
                        ? AppColorsLight.disabled_grey
                        : AppColorsDark.disabled_grey,
                    colorToggle: colorToggle),

                Spacer(),
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
                                        : AppColorsDark.expiration_background),
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 16.0, bottom: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        backgroundColor: user?.photoURL == null
                            ? colorToggle == "light"
                                ? AppColorsLight.main_purple_light
                                : AppColorsDark.main_purple
                            : Colors.transparent,
                        child: user?.photoURL == null
                            ? Icon(Icons.person,
                                color: colorToggle == "light"
                                    ? AppColorsLight.pure_white
                                    : AppColorsDark.pure_white)
                            : null,
                      ),
                      SizedBox(width: 20),
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
                              'Student',
                              style: TextStyle(
                                  color: colorToggle == "light"
                                      ? AppColorsLight.disabled_grey
                                      : AppColorsDark.disabled_grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.exit_to_app,
                            color: colorToggle == "light"
                                ? AppColorsLight.pure_white
                                : AppColorsDark.black),
                        onPressed: _showSignOutDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: mainContent,
            ),
          ),
        ],
      ),
    );
  }
}

class StatisticBox extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;
  final double topMargin;
  final double bottomMargin;
  final double leftMargin;
  final double rightMargin;
  final String colorToggle; // Add a color parameter

  const StatisticBox({
    required this.iconPath,
    required this.label,
    required this.value,
    required this.topMargin,
    required this.bottomMargin,
    required this.leftMargin,
    required this.rightMargin,
    required this.colorToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 872) / 3,
      height: 100, // Fixed height for each box
      margin: EdgeInsets.only(
          top: topMargin,
          bottom: bottomMargin,
          left: leftMargin,
          right: rightMargin),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorToggle == "light"
            ? AppColorsLight.pure_white
            : AppColorsDark.card_background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: colorToggle == "light"
                ? AppColorsLight.light_grey
                : AppColorsDark.light_grey,
            width: 1),
      ),
      child: Row(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Calculate the size as the minimum of the available width and height to maintain a 1:1 ratio
              double size = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;
              return SvgPicture.asset(
                iconPath,
                // Set both height and width to the calculated size to maintain 1:1 aspect ratio
                height: size * 0.8,
                width: size * 0.8,
              );
            },
          ),
          SizedBox(width: 20),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorToggle == "light"
                        ? AppColorsLight.dark_grey
                        : AppColorsDark.dark_grey,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle overflow
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExamRow extends StatefulWidget {
  final String examName;
  final String examId;
  final String date;
  final String time;
  final List<String> students;
  final String score; // Changed from double to String to handle "x/y" format
  final Function(String examId) onRowClick;
  final String colorToggle; // Add a color parameter

  const ExamRow(
      {required this.examName,
      required this.examId,
      required this.date,
      required this.time,
      required this.students,
      required this.score,
      required this.onRowClick,
      required this.colorToggle});

  @override
  _ExamRowState createState() => _ExamRowState();
}

class _ExamRowState extends State<ExamRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    List<String> scoreParts = widget.score.split('/');
    double score = double.tryParse(scoreParts[0]) ?? 0;
    double maxScore = double.tryParse(scoreParts[1]) ?? 100;
    double percentage = (score / maxScore) * 100;

    return GestureDetector(
      onTap: () {
        widget.onRowClick(widget.examId);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          color: _isHovered
              ? widget.colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark.card_background
              : widget.colorToggle == "light"
                  ? AppColorsLight.pure_white
                  : AppColorsDark.pure_white,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    widget.examName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.dark_grey
                          : AppColorsDark.dark_grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  widget.date,
                  style: TextStyle(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.dark_grey
                        : AppColorsDark.dark_grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  widget.time,
                  style: TextStyle(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.dark_grey
                        : AppColorsDark.dark_grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    ...widget.students.take(4).map((_) => Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: CircleAvatar(
                            backgroundColor: widget.colorToggle == "light"
                                ? AppColorsLight.light_grey
                                : AppColorsDark.light_grey,
                            child: Icon(Icons.person,
                                color: widget.colorToggle == "light"
                                    ? AppColorsLight.pure_white
                                    : AppColorsDark.pure_white,
                                size: 16),
                            radius: 12,
                          ),
                        )),
                    if (widget.students.length > 4)
                      Text('+${widget.students.length - 4}',
                          style: TextStyle(
                              color: widget.colorToggle == "light"
                                  ? AppColorsLight.dark_grey
                                  : AppColorsDark.dark_grey)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Stack(
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.colorToggle == "light"
                                  ? AppColorsLight.main_purple
                                  : AppColorsDark.main_purple,
                            ),
                          ),
                        ),
                        Text(
                          '${score.toInt()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.colorToggle == "light"
                                ? AppColorsLight.black
                                : AppColorsDark.black,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
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

class ExamRowSimple extends StatelessWidget {
  final String examName;
  final String description;
  final String formattedDateTime;
  final IconData icon;
  final String colorToggle; // Add a color parameter

  const ExamRowSimple(
      {required this.examName,
      required this.description,
      required this.formattedDateTime,
      required this.icon,
      required this.colorToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorToggle == "light"
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: colorToggle == "light"
                          ? AppColorsLight.dark_grey
                          : AppColorsDark.dark_grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      color: colorToggle == "light"
                          ? AppColorsLight.dark_grey
                          : AppColorsDark.dark_grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color; // Add a color parameter
  final String colorToggle; // Add a color parameter

  const MenuButton(
      {super.key,
      required this.icon,
      required this.label,
      this.color = Colors.grey, // Default color is grey if not specified
      required this.colorToggle});

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered
            ? widget.colorToggle == "light"
                ? AppColorsLight.main_purple_light
                : AppColorsDark.main_purple_light
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
