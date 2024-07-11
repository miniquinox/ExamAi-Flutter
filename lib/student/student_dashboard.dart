import 'package:examai_flutter/student/takeExam_examSelection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

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

// Assuming MenuButton, StatisticBox, StudentRow, and ExamRow are defined elsewhere

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  User? user;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(
          0xFFFCFCFD), // Set the background color of the Scaffold to #fcfcfd
      body: Row(
        children: [
          // Left menu
          Container(
            width: 250,
            color: Color(0xFF6938EF),
            child: Column(
              children: [
                // Exam AI header
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
                // Menu items
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
                // Profile image and name from Google Sign-In
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
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(width: 10),
                      Text(
                        user?.displayName?.substring(0, 17) ?? 'No Name',
                        style: TextStyle(color: Colors.white),
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
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 17), // Add horizontal padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Welcome back, ${user?.displayName}!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Here\'s what\'s happening with your exams today.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      // Statistic boxes
                      Container(
                        height:
                            200, // Set the height of the entire row to 200 pixels
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio:
                                    (MediaQuery.of(context).size.width / 2) /
                                        300, // Adjusted for fixed height of 80
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, bottom: 10.0),
                                    child: StatisticBox(
                                      icon: Icons.book,
                                      label: 'Biology',
                                      value: '80',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, bottom: 10.0),
                                    child: StatisticBox(
                                      icon: Icons.calculate,
                                      label: 'Math',
                                      value: '60',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, right: 10.0),
                                    child: StatisticBox(
                                      icon: Icons.science,
                                      label: 'Physics',
                                      value: '55',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, left: 10.0),
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
                                  border: Border.all(
                                      color: Color(0xFFD0D5DD), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text('Overall Performance',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              height:
                                                  120, // Increase the size of the CircularProgressIndicator
                                              width:
                                                  120, // Increase the size of the CircularProgressIndicator
                                              child: CircularProgressIndicator(
                                                value: 0.8,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Color(0xFF6938EF)),
                                                strokeWidth: 10,
                                              ),
                                            ),
                                            Text('80%',
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                                  border: Border.all(
                                      color: Color(0xFFD0D5DD), width: 1),
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      'The human body',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
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
                      // Recent exams
                      // Recent and Upcoming exams
                      Container(
                        height: MediaQuery.of(context).size.height -
                            350, // Subtract the height of other elements
                        child: Row(
                          children: [
                            // Recent exams
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Color(0xFFD0D5DD),
                                      width:
                                          1), // Outline of 1px with color #D0D5DD
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Recent exams',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 3, child: Text('Exam Name')),
                                        Expanded(flex: 1, child: Text('Date')),
                                        Expanded(flex: 2, child: Text('Time')),
                                        Expanded(
                                            flex: 2, child: Text('Students')),
                                        Expanded(flex: 1, child: Text('Score')),
                                      ],
                                    ),
                                    Divider(),
                                    ExamRow(
                                      examName: 'Math101 Midterm',
                                      examId: 'm101mt',
                                      date: '2023-10-05',
                                      time: '90 mins',
                                      students: [
                                        'Alice',
                                        'Bob',
                                        'Charlie',
                                        'Diana',
                                        'Charlie',
                                        'Diana'
                                      ],
                                      score: 78,
                                    ),
                                    ExamRow(
                                      examName: 'Physics161 Quiz',
                                      examId: 'p161qz',
                                      date: '2023-10-10',
                                      time: '45 mins',
                                      students: [
                                        'Eva',
                                        'Frank',
                                        'Grace',
                                        'Hank',
                                        'Eva',
                                        'Frank',
                                        'Grace',
                                      ],
                                      score: 82,
                                    ),
                                    ExamRow(
                                      examName: 'Chemistry101 Lab',
                                      examId: 'c101lb',
                                      date: '2023-10-15',
                                      time: '120 mins',
                                      students: ['Ivy', 'John', 'Karen', 'Leo'],
                                      score: 89,
                                    ),
                                    ExamRow(
                                      examName: 'Biology150 Final',
                                      examId: 'b150fn',
                                      date: '2023-10-20',
                                      time: '120 mins',
                                      students: [
                                        'Mia',
                                        'Noah',
                                        'Olivia',
                                        'Pablo',
                                        'Olivia',
                                        'Pablo'
                                      ],
                                      score: 94,
                                    ),
                                    ExamRow(
                                      examName: 'English210 Essay',
                                      examId: 'e210es',
                                      date: '2023-10-25',
                                      time: '60 mins',
                                      students: [
                                        'Quinn',
                                        'Riley',
                                        'Sam',
                                        'Tina',
                                        'Quinn',
                                        'Riley',
                                        'Sam',
                                        'Tina',
                                        'Quinn',
                                        'Riley',
                                        'Sam',
                                        'Tina'
                                      ],
                                      score: 76,
                                    ),
                                    ExamRow(
                                      examName: 'Computer Science101 Project',
                                      examId: 'cs101pj',
                                      date: '2023-11-01',
                                      time: 'Continuous Assessment',
                                      students: [
                                        'Uma',
                                        'Vince',
                                        'Wendy',
                                        'Xander',
                                        'Quinn',
                                        'Riley',
                                        'Sam',
                                        'Tina'
                                      ],
                                      score: 88,
                                    ),
                                    ExamRow(
                                      examName: 'Sociology201 Presentation',
                                      examId: 's201pr',
                                      date: '2023-11-05',
                                      time: '30 mins',
                                      students: [
                                        'Yara',
                                        'Zane',
                                        'Alice',
                                        'Bob'
                                      ],
                                      score: 91,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            // Upcoming exams
                            Container(
                              width: 400, // Fixed width for the right column
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Color(0xFFD0D5DD), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Upcoming exams',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    SizedBox(height: 10),
                                    Expanded(
                                      child: ListView(
                                        children: [
                                          ExamRowSimple(
                                            examName: 'Math101',
                                            description: 'Exam 1',
                                            date: 'July 24',
                                            icon: Icons
                                                .calculate, // Math-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'Chem101',
                                            description: 'Midterm Exam',
                                            date: 'July 28',
                                            icon: Icons
                                                .science, // Chemistry-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'Math102',
                                            description: 'Quiz 1',
                                            date: 'July 29',
                                            icon: Icons
                                                .calculate, // Math-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'Bio150',
                                            description: 'Final Exam',
                                            date: 'July 30',
                                            icon: Icons
                                                .biotech, // Biology-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'Phys151',
                                            description: 'Midterm Exam',
                                            date: 'Aug 24',
                                            icon: Icons
                                                .science, // Physics-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'CS101',
                                            description: 'Project Presentation',
                                            date: 'Sept 5',
                                            icon: Icons
                                                .computer, // Computer Science-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'GenEd200',
                                            description: 'Essay Submission',
                                            date: 'Sept 15',
                                            icon: Icons
                                                .book, // General Education-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'Soc101',
                                            description: 'Group Discussion',
                                            date: 'Sept 24',
                                            icon: Icons
                                                .people, // Sociology-related icon
                                          ),
                                          ExamRowSimple(
                                            examName: 'Geo101',
                                            description: 'Fieldwork Report',
                                            date: 'Sept 24',
                                            icon: Icons
                                                .public, // Geography-related icon
                                          ),
                                        ],
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
                ),
              ),
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
      height: 200, // Updated height to 200
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

class ExamRow extends StatelessWidget {
  final String examName;
  final String examId;
  final String date;
  final String time;
  final List<String> students;
  final double score;

  const ExamRow({
    required this.examName,
    required this.examId,
    required this.date,
    required this.time,
    required this.students,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
              flex: 3, // Wider exam name column
              child: Text(examName,
                  style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
              flex: 1,
              child: Text(date, style: TextStyle(color: Colors.grey[700]))),
          Expanded(
              flex: 2,
              child: Text(time, style: TextStyle(color: Colors.grey[700]))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                ...students.take(4).map((_) => Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child:
                            Icon(Icons.person, color: Colors.white, size: 16),
                        radius: 12,
                      ),
                    )),
                if (students.length > 4)
                  Text('+${students.length - 4}',
                      style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          Expanded(
            flex: 1, // Narrower score column
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                    ),
                    Text('${score.toInt()}%', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExamRowSimple extends StatelessWidget {
  final String examName;
  final String description;
  final String date;
  final IconData icon;

  const ExamRowSimple({
    required this.examName,
    required this.description,
    required this.date,
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
          )),
          Text(date, style: TextStyle(color: Colors.grey[700])),
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
