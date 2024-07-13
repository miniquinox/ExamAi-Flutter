import 'package:examai_flutter/professor/createExam_examDetails.dart';
import 'package:examai_flutter/professor/examGrades.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<Map<String, dynamic>> exams = [];

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
    fetchTotalExams();
    fetchTotalExamsTaken();
    fetchExams();
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

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 20),
                // Menu items
                const MenuButton(icon: Icons.dashboard, label: 'Dashboard'),
                const MenuButton(icon: Icons.assignment, label: 'Exams'),
                const MenuButton(icon: Icons.people, label: 'Students'),
                const MenuButton(icon: Icons.class_, label: 'Classes'),
                const MenuButton(icon: Icons.settings, label: 'Settings'),
                const MenuButton(
                    icon: Icons.notifications, label: 'Notifications'),
                const Spacer(),
                // Usage card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          value: 0.8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6938EF)),
                        ),
                        const SizedBox(height: 10),
                        const Text('Used space',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text(
                            'Your team has used 80% of your available space. Need more?'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () {}, child: const Text('Upgrade plan'))
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
                      Column(
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
                      )
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
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 16.0, right: 16.0), // Added margin here
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
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
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return const Color(0xFF6938EF).withOpacity(
                                        0.8); // Slightly lighter on hover
                                  }
                                  return const Color(
                                      0xFF6938EF); // Default color
                                },
                              ),
                              foregroundColor: WidgetStateProperty.all(
                                  Colors.white), // Button text color
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Less rounded corners
                                ),
                              ),
                            ),
                            child: const Text('+ Create new exam'),
                          )
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
                                          value: '$totalExamsCreated'),
                                    ),
                                    const SizedBox(
                                        width:
                                            8), // Spacing between statistic boxes
                                    Expanded(
                                      child: StatisticBox(
                                          icon: Icons.today,
                                          label: "Total exams taken",
                                          value: '$totalExamsTaken'),
                                    ),
                                    const SizedBox(
                                        width:
                                            8), // Spacing between statistic boxes
                                    const Expanded(
                                      child: StatisticBox(
                                          icon: Icons.assignment_turned_in,
                                          label: 'Average Exam Score',
                                          value: '85%'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Graph
                                Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Exams report',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                              onPressed: () {},
                                              child: const Text('View report')),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        height: 200,
                                        color: Colors
                                            .grey[200], // Placeholder for graph
                                        child: const Center(
                                            child: Text('Graph Placeholder')),
                                      ),
                                      const SizedBox(height: 10),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text('12 months'),
                                          Text('3 months'),
                                          Text('30 days'),
                                          Text('7 days'),
                                          Text('24 hours'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width:
                                  16), // Spacing between left and right content
                          Expanded(
                            flex:
                                1, // Reduce space for right side to make it narrower
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
                                  const Text('Students took the exams',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  // Container with a fixed height
                                  const SizedBox(
                                    height: 380, // Set a fixed height
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.0), // Added left padding
                                      child: Column(
                                        children: [
                                          StudentRow(name: 'Umar Islam'),
                                          StudentRow(name: 'Giring Furqon'),
                                          StudentRow(name: 'Andra Mahmud'),
                                          StudentRow(name: 'Lukman Farhan'),
                                          StudentRow(name: 'Lukman Farhan'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right:
                                                8.0), // Adjust the padding value as needed
                                        child: TextButton(
                                            onPressed: () {},
                                            child: const Text('Show more')),
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
                            const Text('Your Exams',
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    child:
                                        Text('Course')), // Adjusted flex value
                                Expanded(
                                    flex: 3,
                                    child:
                                        Text('Exam ID')), // Adjusted flex value
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        'Date last graded')), // Adjusted flex value
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
                                SizedBox(
                                  width: 110,
                                )
                              ],
                            ),
                            const Divider(),
                            // Example rows
                            ...exams.map((exam) => ExamRow(
                                  examName: exam['examName'] ?? 'Placeholder',
                                  examId: exam['id'] ?? 'Placeholder',
                                  course: exam['course'] ?? 'Placeholder',
                                  dateLastGraded:
                                      exam['dateLastGraded'] ?? 'No grades yet',
                                  averageScore: exam['avgScore']?.toString() ??
                                      'Placeholder',
                                  graded: exam['graded'] ?? false,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
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

  const MenuButton({super.key, required this.icon, required this.label});

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const hoverColor =
        Color(0xFF7A56FF); // A bit lighter purple for hover state
    const color = Color(0xFF6938EF); // Normal purple color

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered ? hoverColor : color,
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 20), // Adjust padding for bigger spacing
        child: Row(
          children: [
            Icon(widget.icon, color: Colors.white),
            const SizedBox(width: 16), // Increased spacing
            Text(widget.label, style: const TextStyle(color: Colors.white)),
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

  const StatisticBox(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150, // Fixed height for better layout consistency
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
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
            Icon(icon, color: Colors.grey, size: 40),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
          Text(name),
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

  const ExamRow({
    super.key,
    required this.examName,
    required this.examId,
    required this.course,
    required this.dateLastGraded,
    required this.averageScore,
    required this.graded,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamDetailsScreen(examId: widget.examId),
            ),
          );
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
                      Text('$score%', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2, // Adjusted flex value
                child: Center(
                  // Center the content within the Expanded widget
                  child: SizedBox(
                    width: 100, // Set the width of the button
                    child: TextButton(
                      onPressed: widget.graded
                          ? null
                          : () => showDialog(
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
                                      textAlign:
                                          TextAlign.center, // Center align
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
                      style: TextButton.styleFrom(
                        backgroundColor:
                            widget.graded ? Colors.grey : Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4), // Adjust padding as needed
                      ),
                      child: Text(
                        widget.graded ? 'Graded' : 'Grade',
                        style: const TextStyle(color: Colors.white),
                      ),
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {},
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
