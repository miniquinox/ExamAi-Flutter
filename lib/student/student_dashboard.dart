import 'package:examai_flutter/main.dart';
import 'package:examai_flutter/student/studentExam_feedback.dart';
import 'package:examai_flutter/student/takeExam_examSelection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
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

          final finalGrade =
              gradedSnapshot.exists && gradedSnapshot.data() != null
                  ? gradedSnapshot.data()!['final_grade'] ?? 0
                  : 0;

          totalScore += finalGrade;
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

      if (examCount > 0) {
        averageScore = totalScore / examCount;
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

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (selectedExamId == null) {
      mainContent = SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.displayName}!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Here\'s what\'s happening with your exams today.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty2.svg',
                              label: 'Homework 1',
                              value: 'Not graded',
                              topMargin: 0,
                              bottomMargin: 10,
                              leftMargin: 10,
                              rightMargin: 10,
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty3.svg',
                              label: 'Quiz 1',
                              value: 'Not graded',
                              topMargin: 0,
                              bottomMargin: 10,
                              leftMargin: 10,
                              rightMargin: 0,
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
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty5.svg',
                              label: 'Homework 2',
                              value: 'Not graded',
                              topMargin: 10,
                              bottomMargin: 0,
                              leftMargin: 10,
                              rightMargin: 10,
                            ),
                            StatisticBox(
                              iconPath: 'assets/images/empty6.svg',
                              label: 'Quiz 2',
                              value: 'Not graded',
                              topMargin: 10,
                              bottomMargin: 0,
                              leftMargin: 10,
                              rightMargin: 0,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFD0D5DD), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text('Overall Performance',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF6938EF)),
                                    strokeWidth: 10,
                                  ),
                                ),
                                Text('${averageScore.toInt()}%',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
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
                      color: Color(0xFF6938EF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFD0D5DD), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s Exam',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text(
                          '11:24 AM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Biology',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          'The human body',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '12 : 24 : 00 PM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFD0D5DD), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent exams',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text('Exam Name'),
                                ),
                              ),
                              Expanded(flex: 1, child: Text('Date')),
                              Expanded(flex: 2, child: Text('Time')),
                              Expanded(flex: 2, child: Text('Students')),
                              Expanded(flex: 1, child: Text('Score')),
                            ],
                          ),
                          recentExams.length == 0
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 50),
                                      Text(
                                        "No available exams yet",
                                        style: TextStyle(
                                          fontSize: 16,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFD0D5DD), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upcoming exams',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: upcomingExams.length,
                              itemBuilder: (context, index) {
                                final exam = upcomingExams[index];
                                return ExamRowSimple(
                                  examName: exam['examName'] ?? 'Placeholder',
                                  description:
                                      exam['description'] ?? 'Placeholder',
                                  formattedDateTime:
                                      exam['formattedDateTime'] ??
                                          'Placeholder',
                                  icon: Icons.calendar_today,
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
      mainContent = StudentExamFeedbackScreen(examId: feedbackExamId!);
    } else {
      mainContent = ExamResultsScreen(
        examId: selectedExamId!,
        onFeedbackClick: onFeedbackClick,
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
      backgroundColor: Color(0xFFFCFCFD),
      body: Row(
        children: [
          Container(
            width: 250,
            color: Color(0xFF6938EF),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 16.0, bottom: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Exam AI',
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            StudentScreen(),
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
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentPortalScreen()),
                    );
                  },
                  child: MenuButton(
                      icon: Icons.assignment,
                      label: 'Exams',
                      color: Colors.white),
                ),
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
                Spacer(),
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
                        // ElevatedButton(
                        //     onPressed: () {}, child: Text('Upgrade plan'))
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
                            ? Color(0xFF6938EF)
                            : Colors.transparent,
                        child: user?.photoURL == null
                            ? Icon(Icons.person, color: Colors.white)
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
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Text(
                              'Student',
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

  const StatisticBox({
    required this.iconPath,
    required this.label,
    required this.value,
    required this.topMargin,
    required this.bottomMargin,
    required this.leftMargin,
    required this.rightMargin,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFD0D5DD), width: 1),
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
                Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  final double score;
  final Function(String examId) onRowClick;

  const ExamRow({
    required this.examName,
    required this.examId,
    required this.date,
    required this.time,
    required this.students,
    required this.score,
    required this.onRowClick,
  });

  @override
  _ExamRowState createState() => _ExamRowState();
}

class _ExamRowState extends State<ExamRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onRowClick(widget.examId);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          color: _isHovered ? Color(0xFFD2D5DC) : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              ),
              Expanded(
                flex: 1,
                child: Text(widget.date,
                    style: TextStyle(color: Colors.grey[700])),
              ),
              Expanded(
                flex: 2,
                child: Text(widget.time,
                    style: TextStyle(color: Colors.grey[700])),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    ...widget.students.take(4).map((_) => Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.person,
                                color: Colors.white, size: 16),
                            radius: 12,
                          ),
                        )),
                    if (widget.students.length > 4)
                      Text('+${widget.students.length - 4}',
                          style: TextStyle(color: Colors.grey[700])),
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
                            value: widget.score / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        ),
                        Text('${widget.score.toInt()}%',
                            style: TextStyle(fontSize: 12)),
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

  const ExamRowSimple({
    required this.examName,
    required this.description,
    required this.formattedDateTime,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF6938EF)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(examName, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formattedDateTime,
                    style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
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
