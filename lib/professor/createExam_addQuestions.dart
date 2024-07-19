import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'createExam_review.dart'; // Ensure you have this import

class CreateExamAddQuestions extends StatefulWidget {
  final String examName;
  final String course;
  final String date;
  final String time;
  final List<String> students;
  final String? examId;

  const CreateExamAddQuestions({
    required this.examName,
    required this.course,
    required this.date,
    required this.time,
    required this.students,
    this.examId,
  });

  @override
  _CreateExamAddQuestionsState createState() => _CreateExamAddQuestionsState();
}

class _CreateExamAddQuestionsState extends State<CreateExamAddQuestions> {
  List<Map<String, dynamic>> questions = [
    {'question': TextEditingController(), 'weight': 20, 'rubrics': []}
  ];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.examId != null) {
      _loadExamData(widget.examId!);
    }
  }

  Future<void> _loadExamData(String examId) async {
    try {
      DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
          .collection('Exams')
          .doc(examId)
          .get();

      if (examSnapshot.exists) {
        Map<String, dynamic> data = examSnapshot.data() as Map<String, dynamic>;
        List<dynamic> questionData = data['questions'] ?? [];
        setState(() {
          questions = questionData.map((q) {
            List<dynamic> rubricData = q['rubrics'] ?? [];
            return {
              'question': TextEditingController(text: q['question']),
              'weight': q['weight'] ?? 20,
              'rubrics': rubricData.map((r) {
                return {
                  'rubric': TextEditingController(text: r['rubric']),
                  'weight': r['weight'] ?? 10,
                };
              }).toList(),
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error loading exam data: $e");
    }
  }

  void addQuestion() {
    setState(() {
      questions.add(
          {'question': TextEditingController(), 'weight': 20, 'rubrics': []});
    });
  }

  void addRubric(int index) {
    setState(() {
      questions[index]['rubrics']
          .add({'rubric': TextEditingController(), 'weight': 10});
    });
  }

  void removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
  }

  void removeRubric(int questionIndex, int rubricIndex) {
    setState(() {
      questions[questionIndex]['rubrics'].removeAt(rubricIndex);
    });
  }

  List<Map<String, dynamic>> formatQuestionsForReview() {
    return questions.map((question) {
      return {
        'question': question['question'].text,
        'weight': question['weight'],
        'rubrics': question['rubrics'].map((rubric) {
          return {
            'rubric': rubric['rubric'].text,
            'weight': rubric['weight'],
          };
        }).toList(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFD),
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
              'Create new exam',
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
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: _buildProgressColumn(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 100.0),
              child: _buildFormColumn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressColumn() {
    return Container(
      width: 225,
      padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildStepper(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep(
          title: 'Exam Details',
          subtitle: 'Enter basic information',
          isActive: false,
          isCompleted: true,
        ),
        _buildStep(
          title: 'Add Questions',
          subtitle: 'Create and edit questions',
          isActive: true,
          isCompleted: false,
        ),
        _buildStep(
          title: 'Review',
          subtitle: 'Check and review the exam',
          isActive: false,
          isCompleted: false,
        )
      ],
    );
  }

  Widget _buildStep(
      {required String title,
      required String subtitle,
      required bool isActive,
      required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isActive
                    ? Color(0xFF6938EF)
                    : isCompleted
                        ? Colors.green
                        : Colors.grey,
                child: Icon(isActive ? Icons.check_circle : Icons.circle,
                    color: Colors.white, size: 16),
              ),
              Container(
                height: 40,
                width: 2,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
            ],
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Color(0xFF6938EF) : Colors.black),
              ),
              Text(
                subtitle,
                style: TextStyle(
                    fontSize: 14,
                    color: isActive ? Color(0xFF6938EF) : Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormColumn() {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('Add Questions',
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: _buildQuestionFields(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text('Back'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateExamReview(
                                    examName: widget.examName,
                                    course: widget.course,
                                    date: widget.date,
                                    time: widget.time,
                                    students: widget.students,
                                    questions: formatQuestionsForReview(),
                                    examId:
                                        widget.examId, // Pass the examId here
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF6938EF),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionFields() {
    List<Widget> questionFields = [];
    for (int i = 0; i < questions.length; i++) {
      questionFields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xfffcfcfd),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Color(0xffcbcfd7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Question ${i + 1}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          questions[i]['weight']--;
                        });
                      },
                    ),
                    Text('${questions[i]['weight']}'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          questions[i]['weight']++;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        removeQuestion(i);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: questions[i]['question'],
                  decoration: InputDecoration(
                    labelText: 'Enter question',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines:
                      null, // Allows the text field to expand vertically based on content
                ),
                SizedBox(height: 8),
                ..._buildRubricFields(i),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => addRubric(i),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF6938EF),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('+ Add Rubric'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: addQuestion,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF6938EF),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('+ Add Question'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return questionFields;
  }

  List<Widget> _buildRubricFields(int questionIndex) {
    List<Widget> rubricFields = [];
    for (int i = 0; i < questions[questionIndex]['rubrics'].length; i++) {
      rubricFields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: questions[questionIndex]['rubrics'][i]
                        ['rubric'],
                    decoration: InputDecoration(
                      labelText: 'Enter rubric description',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines:
                        null, // Allows the text field to expand vertically based on content
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      questions[questionIndex]['rubrics'][i]['weight']--;
                    });
                  },
                ),
                Text('${questions[questionIndex]['rubrics'][i]['weight']}'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      questions[questionIndex]['rubrics'][i]['weight']++;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    removeRubric(questionIndex, i);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    return rubricFields;
  }
}

void main() => runApp(MaterialApp(
      home: CreateExamAddQuestions(
        examName: 'Sample Exam',
        course: 'Sample Course',
        date: '01/01/2024',
        time: '10:00 AM',
        students: ['Student 1', 'Student 2'],
      ),
    ));
