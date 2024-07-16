import 'package:examai_flutter/main.dart';
import 'package:examai_flutter/student/takeExam_examSelection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    print('Fetching recent exams for email: $email');
    final studentDoc = await FirebaseFirestore.instance
        .collection('Students')
        .doc(email)
        .get();

    if (studentDoc.exists) {
      final completedExams =
          studentDoc.data()?['completedExams'] as Map<String, dynamic>? ?? {};

      print('Completed exams map size: ${completedExams.length}');
      completedExams.forEach((examId, examData) {
        print('Found completed exam with ID: $examId');
      });

      for (var examId in completedExams.keys) {
        // final examData = completedExams[examId];

        print('Processing exam ID: $examId');

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

          recentExams.add({
            'examName': examDetails['examName'] ?? 'Placeholder',
            'examId': examId,
            'date': examDetails['date'] ?? 'Placeholder',
            'time': examDetails['time'] ?? 'Placeholder',
            'students': List<String>.from(examDetails['students'] ?? []),
            'score': finalGrade,
          });
        } else {
          print('Exam snapshot does not exist for $examId');
        }
      }

      setState(() {});
    } else {
      print('No document found for student with email: $email');
    }
  }

  Future<void> fetchUpcomingExams(String email) async {
    print('Fetching upcoming exams for email: $email');
    final studentDoc = await FirebaseFirestore.instance
        .collection('Students')
        .doc(email)
        .get();

    if (studentDoc.exists) {
      final currentExams =
          List<String>.from(studentDoc.data()?['currentExams'] ?? []);
      print('Current exams for student: $currentExams');

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
            } catch (e) {
              print('Error formatting date and time: $e');
            }

            upcomingExams.add({
              'examId': examId,
              'examName': examDetails['examName'] ?? 'Placeholder',
              'description': examDetails['course'] ?? 'Upcoming Exam',
              'formattedDateTime': formattedDateTime,
            });
          }
        }
      }

      print('List of Upcoming exams:');
      for (var exam in upcomingExams) {
        print(
            '- ${exam['examId']}, ${exam['description']}, ${exam['examName']}, ${exam['formattedDateTime']}');
      }

      setState(() {});
    } else {
      print('No document found for student with email: $email');
    }
  }

  void onExamRowClick(String examId) {
    setState(() {
      selectedExamId = examId;
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
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio:
                          (MediaQuery.of(context).size.width / 2) / 300,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 10.0, bottom: 10.0),
                          child: StatisticBox(
                            icon: Icons.book,
                            label: 'Biology',
                            value: '80',
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, bottom: 10.0),
                          child: StatisticBox(
                            icon: Icons.calculate,
                            label: 'Math',
                            value: '60',
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, right: 10.0),
                          child: StatisticBox(
                            icon: Icons.science,
                            label: 'Physics',
                            value: '55',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                          child: StatisticBox(
                            icon: Icons.computer,
                            label: 'Computer',
                            value: '75',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 2,
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
                                      value: 0.8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF6938EF)),
                                      strokeWidth: 10,
                                    ),
                                  ),
                                  Text('80%',
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
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
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
                    ),
                  ),
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
    } else {
      mainContent = ExamResultsScreen(examId: selectedExamId!);
    }

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
                MenuButton(icon: Icons.dashboard, label: 'Dashboard'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentPortalScreen()),
                    );
                  },
                  child: MenuButton(icon: Icons.assignment, label: 'Exams'),
                ),
                MenuButton(icon: Icons.people, label: 'Students'),
                MenuButton(icon: Icons.class_, label: 'Classes'),
                MenuButton(icon: Icons.settings, label: 'Settings'),
                MenuButton(icon: Icons.notifications, label: 'Notifications'),
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
                        CircularProgressIndicator(
                          value: 0.8,
                          backgroundColor: Colors.grey[200],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF6938EF)),
                        ),
                        SizedBox(height: 10),
                        Text('Used space',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            'Your team has used 80% of your available space. Need more?'),
                        SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () {}, child: Text('Upgrade plan'))
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
  final IconData icon;
  final String label;
  final String value;

  const StatisticBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFD0D5DD), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 30),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
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

  const MenuButton({Key? key, required this.icon, required this.label})
      : super(key: key);

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor =
        Color(0xFF7A56FF); // A bit lighter purple for hover state
    final color = Color(0xFF6938EF); // Normal purple color

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered ? hoverColor : color,
        padding: EdgeInsets.symmetric(
            vertical: 10, horizontal: 20), // Adjust padding for bigger spacing
        child: Row(
          children: [
            Icon(widget.icon, color: Colors.white),
            SizedBox(width: 16), // Increased spacing
            Text(widget.label, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
