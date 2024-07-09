import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentPortalScreen extends StatefulWidget {
  @override
  _StudentPortalScreenState createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  User? user;
  List<Map<String, dynamic>> exams = [];

  @override
  void initState() {
    super.initState();
    fetchUserAndExams();
  }

  Future<void> fetchUserAndExams() async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(user!.email)
          .get();

      final currentExams =
          List<String>.from(studentDoc.data()?['currentExams'] ?? []);

      for (String examId in currentExams) {
        final examDoc = await FirebaseFirestore.instance
            .collection('Exams')
            .doc(examId)
            .get();

        if (examDoc.exists) {
          exams.add({
            'id': examDoc.id,
            ...examDoc.data()!,
          });
        }
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffcfcfe),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.home, color: Colors.black),
            SizedBox(width: 4),
            Text(
              'Home',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.black),
            SizedBox(width: 4),
            Icon(Icons.assignment, color: Color(0xFF6938EF)),
            SizedBox(width: 4),
            Text(
              'Exams',
              style: TextStyle(
                  color: Color(0xFF6938EF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Spacer(),
            CircleAvatar(
              backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? ''),
              backgroundColor: Colors.transparent,
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.start, // Aligns children to the start
            spacing: 16,
            runSpacing: 16,
            children: exams.map((exam) => buildExamCard(exam)).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildExamCard(Map<String, dynamic> exam) {
    return Container(
      width: 500,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        color: Colors.white, // Set the background color to white
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 1.0), // Add outline
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0, // Remove shadow
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam['course'] ?? 'Placeholder',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                exam['examName'] ?? 'Placeholder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align to the start
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Align column contents to the start
                    children: [
                      Text('Professor', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          exam['professorURL'] != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(exam['professorURL']),
                                  radius: 24,
                                )
                              : CircleAvatar(
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                  backgroundColor:
                                      Colors.blue, // Or any other color
                                  radius: 24,
                                ),
                          SizedBox(width: 10),
                          Text(
                            exam['professorName'] != null &&
                                    exam['professorName'].length > 18
                                ? '${exam['professorName'].substring(0, 18)}...'
                                : exam['professorName'] ??
                                    'Joaquin Carretero...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 40), // Space between columns
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align column contents to the start
                      children: [
                        Text('Students', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 5),
                        Wrap(
                          spacing: 8, // Gap between each circle avatar
                          children: [
                            ...List.generate(
                              (exam['students']?.length ?? 0) > 4
                                  ? 4
                                  : exam['students']?.length ?? 0,
                              (index) => CircleAvatar(
                                backgroundColor: [
                                  Colors.red,
                                  Colors.green,
                                  Colors.blue,
                                  Colors.purple,
                                ][index %
                                    4], // Corrected modulus based on the actual number of colors
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 16),
                                radius: 12,
                              ),
                            ),
                            if ((exam['students']?.length ?? 0) > 4)
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 12,
                                child: Text(
                                  '+${(exam['students']?.length ?? 0) - 4}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // text Date and Time
              Text(
                "Date and Time",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16),
                  SizedBox(width: 5),
                  Text(exam['date'] ?? 'Placeholder'),
                  SizedBox(width: 10),
                  Icon(Icons.access_time, size: 16),
                  SizedBox(width: 5),
                  Text(exam['time'] ?? 'Placeholder'),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Descriptions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                exam['description'] ?? 'Placeholder',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                child: SizedBox(
                  width: double.infinity, // Expand to the width of the card
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF6938EF),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Start'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: StudentPortalScreen(),
    ));
