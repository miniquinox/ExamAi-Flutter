import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfessorScreen(),
    );
  }
}

// Assuming MenuButton, StatisticBox, StudentRow, and ExamRow are defined elsewhere

class ProfessorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  padding: const EdgeInsets.all(16.0),
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
                MenuButton(icon: Icons.assignment, label: 'Exams'),
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
                // Profile image
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey
                            .shade200, // Optional: Background color of the avatar
                        child: Icon(
                          Icons.person, // Generic person icon
                          color: Colors.blue, // Optional: Icon color
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Joaquin Carretero',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                )
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
                  margin: EdgeInsets.only(
                      left: 16.0, right: 16.0), // Added margin here
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Hello Mr. Vista',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet consectetur. Odio ut nec donec sed.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
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
                                          value: '60'),
                                    ),
                                    // SizedBox(
                                    //     width:
                                    //         8), // Spacing between statistic boxes
                                    // Expanded(
                                    //   child: Container(
                                    //     margin: EdgeInsets.only(left: 8),
                                    //     child: StatisticBox(
                                    //         icon: Icons.assessment,
                                    //         label: 'Today\'s exams taken',
                                    //         value: '150'),
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //     width:
                                    //         8), // Spacing between statistic boxes
                                    // Expanded(
                                    //   child: Container(
                                    //     margin: EdgeInsets.only(left: 8),
                                    //     child: StatisticBox(
                                    //         icon: Icons.assessment,
                                    //         label: 'Average Exam Score',
                                    //         value: '85%'),
                                    //   ),
                                    // ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                // Graph
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Exams report',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          TextButton(
                                              onPressed: () {},
                                              child: Text('View report')),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        height: 200,
                                        color: Colors
                                            .grey[200], // Placeholder for graph
                                        child: Center(
                                            child: Text('Graph Placeholder')),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
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
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          SizedBox(
                              width:
                                  16), // Spacing between left and right content
                          Expanded(
                            flex:
                                1, // Reduce space for right side to make it narrower
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Students took the exams',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  // Container with a fixed height
                                  Container(
                                    height: 375, // Set a fixed height
                                    child: Padding(
                                      padding: const EdgeInsets.only(
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
                                        padding: EdgeInsets.only(
                                            right:
                                                8.0), // Adjust the padding value as needed
                                        child: TextButton(
                                            onPressed: () {},
                                            child: Text('Show more')),
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
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Exams',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: Text('Exam name')),
                                Expanded(child: Text('Exam ID')),
                                Expanded(child: Text('Course')),
                                Expanded(child: Text('Date created')),
                                Expanded(child: Text('Average score')),
                                SizedBox(
                                    width: 24), // Space for edit/delete icons
                              ],
                            ),
                            Divider(),
                            // Example row
                            ExamRow(
                              examName: 'Math 101',
                              examId: '66277431',
                              course: 'Mathematics',
                              dateCreated: 'May 9, 2024',
                              averageScore: '80%',
                            ),
                            ExamRow(
                              examName: 'Physics 201',
                              examId: '66277432',
                              course: 'Physics',
                              dateCreated: 'May 10, 2024',
                              averageScore: '85%',
                            ),
                            ExamRow(
                              examName: 'Chemistry 101',
                              examId: '66277433',
                              course: 'Chemistry',
                              dateCreated: 'May 11, 2024',
                              averageScore: '75%',
                            ),
                            ExamRow(
                              examName: 'Biology 202',
                              examId: '66277434',
                              course: 'Biology',
                              dateCreated: 'May 12, 2024',
                              averageScore: '90%',
                            ),
                            ExamRow(
                              examName: 'English Literature 101',
                              examId: '66277435',
                              course: 'English',
                              dateCreated: 'May 13, 2024',
                              averageScore: '82%',
                            ),
                            ExamRow(
                              examName: 'World History 101',
                              examId: '66277436',
                              course: 'History',
                              dateCreated: 'May 14, 2024',
                              averageScore: '78%',
                            ),
                            ExamRow(
                              examName: 'Computer Science 101',
                              examId: '66277437',
                              course: 'Computer Science',
                              dateCreated: 'May 15, 2024',
                              averageScore: '95%',
                            ),
                            // Add more rows as needed
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

class StatisticBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatisticBox(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 146, // Fixed height for better layout consistency
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey, size: 40),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentRow extends StatelessWidget {
  final String name;

  const StudentRow({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            child: Icon(Icons.person,
                color: Colors.white), // Google icon or similar
            backgroundColor: Colors.blue, // Optional: Change to preferred color
          ),
          SizedBox(width: 10),
          Text(name),
        ],
      ),
    );
  }
}

class ExamRow extends StatelessWidget {
  final String examName;
  final String examId;
  final String course;
  final String dateCreated;
  final String averageScore;

  const ExamRow({
    required this.examName,
    required this.examId,
    required this.course,
    required this.dateCreated,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    double score = double.tryParse(averageScore.replaceAll('%', '')) ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(examName)),
          Expanded(child: Text(examId)),
          Expanded(child: Text(course)),
          Expanded(child: Text(dateCreated)),
          Expanded(
            child: Row(
              children: [
                // Simulated donut chart
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 5,
                      ),
                    ),
                    Text('$score%', style: TextStyle(fontSize: 10)),
                  ],
                ),
                Spacer(),
                // Buttons inside a ButtonBar for minimal alignment
                ButtonBar(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Box extends StatelessWidget {
  final String title;
  final String content;

  const Box({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(content, style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
