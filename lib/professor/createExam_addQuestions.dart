import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors_professor.dart';
import 'createExam_review.dart'; // Ensure you have this import
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

class CreateExamAddQuestions extends StatefulWidget {
  final String examName;
  final String course;
  final String date;
  final String time;
  final List<String> students;
  final String? examId;
  final String colorToggle; // Add a color parameter

  const CreateExamAddQuestions(
      {required this.examName,
      required this.course,
      required this.date,
      required this.time,
      required this.students,
      this.examId,
      required this.colorToggle});

  @override
  _CreateExamAddQuestionsState createState() => _CreateExamAddQuestionsState();
}

class _CreateExamAddQuestionsState extends State<CreateExamAddQuestions>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> questions = [
    {'question': TextEditingController(), 'weight': 20, 'rubrics': []}
  ];
  User? user = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    if (widget.examId != null) {
      _loadExamData(widget.examId!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
  }

  void addRubric(int index) {
    setState(() {
      questions[index]['rubrics']
          .add({'rubric': TextEditingController(), 'weight': 10});
      // Recalculate question total weight based on rubric weights
      _recalculateQuestionWeight(index);
    });
  }

  void removeRubric(int questionIndex, int rubricIndex) {
    setState(() {
      questions[questionIndex]['rubrics'].removeAt(rubricIndex);
      // Recalculate question total weight based on rubric weights
      _recalculateQuestionWeight(questionIndex);
    });
  }

  void _recalculateQuestionWeight(int questionIndex) {
    int totalWeight = 0;
    if (questions[questionIndex]['rubrics'].isNotEmpty) {
      // Sum the weights of all rubrics
      totalWeight = questions[questionIndex]['rubrics']
          .fold(0, (sum, rubric) => sum + rubric['weight']);
    } else {
      // Default to 20 if no rubrics
      totalWeight = 20;
    }

    setState(() {
      questions[questionIndex]['weight'] = totalWeight;
    });
  }

  void _changeRubricWeight(int questionIndex, int rubricIndex, int delta) {
    setState(() {
      // Modify the rubric weight
      questions[questionIndex]['rubrics'][rubricIndex]['weight'] += delta;

      // Prevent the weight from going below 1
      if (questions[questionIndex]['rubrics'][rubricIndex]['weight'] < 1) {
        questions[questionIndex]['rubrics'][rubricIndex]['weight'] = 1;
      }

      // Recalculate the total weight of the question
      _recalculateQuestionWeight(questionIndex);
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

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double progress = _animationController.value;
        final Color color = HSVColor.fromAHSV(
          1.0,
          (progress * 360) % 360,
          1.0,
          1.0,
        ).toColor();

        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: BorderSide(
              color: color,
              width: 2,
            ),
            backgroundColor: AppColorsDark.card_light_background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (context, setState) => ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: GenerateExamPopup(
                    colorToggle: widget
                        .colorToggle, // Dynamically pass the updated value
                    updateQuestions: (newQuestions) {
                      setState(() {
                        questions = newQuestions;
                      });
                    },
                  ),
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Generate Exam with AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colorToggle == "light"
          ? AppColorsLight.lightest_grey
          : AppColorsDark.pure_white,
      appBar: AppBar(
        backgroundColor: widget.colorToggle == "light"
            ? AppColorsLight.light_grey
            : AppColorsDark.light_grey,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.home,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            SizedBox(width: 4),
            Text(
              'Home',
              style: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.black
                      : AppColorsDark.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
            SizedBox(width: 4),
            Icon(
              Icons.assignment,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.main_purple
                  : AppColorsDark.main_purple,
            ),
            SizedBox(width: 4),
            Text(
              'Create new exam',
              style: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.main_purple
                      : AppColorsDark.main_purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Spacer(),
            CircleAvatar(
              backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? ''),
              backgroundColor: Colors.transparent,
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? Icon(
                      Icons.person,
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.pure_white,
                    )
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
          Text(
            'Steps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.colorToggle == "light"
                  ? AppColorsLight.black
                  : AppColorsDark.black,
            ),
          ),
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
                    ? widget.colorToggle == "light"
                        ? AppColorsLight.main_purple
                        : AppColorsDark.main_purple
                    : isCompleted
                        ? Colors.green
                        : widget.colorToggle == "light"
                            ? AppColorsLight.disabled_grey
                            : AppColorsDark.disabled_grey,
                child: Icon(
                  isActive ? Icons.check_circle : Icons.circle,
                  color: Colors.white,
                  size: 16,
                ),
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
                  color: isActive
                      ? widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple
                      : widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive
                      ? widget.colorToggle == "light"
                          ? AppColorsLight.main_purple
                          : AppColorsDark.main_purple
                      : widget.colorToggle == "light"
                          ? AppColorsLight.disabled_grey
                          : AppColorsDark.disabled_grey,
                ),
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
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.pure_white
                      : AppColorsDark.pure_white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.light_grey
                        : AppColorsDark.light_grey,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Add Questions',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: widget.colorToggle == "light"
                                ? AppColorsLight.black
                                : AppColorsDark.black,
                          ),
                        ),
                        SizedBox(width: 30), // Add 30 pixels of space
                        _buildAnimatedButton(),
                      ],
                    ),
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
                              foregroundColor: widget.colorToggle == "light"
                                  ? AppColorsLight.black
                                  : AppColorsDark.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              backgroundColor: widget.colorToggle == "light"
                                  ? AppColorsLight.pure_white
                                  : AppColorsDark.pure_white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                color: widget.colorToggle == "light"
                                    ? AppColorsLight.black
                                    : AppColorsDark.black,
                              ),
                            ),
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
                                    colorToggle: widget.colorToggle,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: widget.colorToggle == "light"
                                  ? AppColorsLight.pure_white
                                  : AppColorsDark.pure_white,
                              backgroundColor: widget.colorToggle == "light"
                                  ? AppColorsLight.main_purple
                                  : AppColorsDark.main_purple,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.colorToggle == "light"
                                    ? AppColorsLight.pure_white
                                    : AppColorsDark.pure_white,
                              ),
                            ),
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
              color: widget.colorToggle == "light"
                  ? AppColorsLight.lightest_grey
                  : AppColorsDark.card_background,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: widget.colorToggle == "light"
                    ? AppColorsLight.light_grey
                    : AppColorsDark.light_grey,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Question ${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                    ),
                    Spacer(),
                    // No more +/- buttons for question weight
                    Text(
                      '${questions[i]['weight']} pts',
                      style: TextStyle(
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
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
                    labelStyle: TextStyle(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                    border: OutlineInputBorder(),
                    fillColor: widget.colorToggle == "light"
                        ? AppColorsLight.light_grey
                        : AppColorsDark.card_light_background,
                    filled: true,
                  ),
                  style: TextStyle(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines:
                      null, // Allows the text field to expand vertically based on content
                ),
                SizedBox(height: 8),
                ..._buildRubricFields(i),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => addRubric(i),
                      style: TextButton.styleFrom(
                        foregroundColor: widget.colorToggle == "light"
                            ? AppColorsLight.main_purple
                            : AppColorsDark.main_purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: widget.colorToggle == "light"
                            ? AppColorsLight.pure_white
                            : AppColorsDark.pure_white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        '+ Add Rubric',
                        style: TextStyle(
                          color: widget.colorToggle == "light"
                              ? AppColorsLight.black
                              : AppColorsDark.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: addQuestion,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                        backgroundColor: widget.colorToggle == "light"
                            ? AppColorsLight.main_purple
                            : AppColorsDark.main_purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        '+ Add Question',
                        style: TextStyle(
                          color: widget.colorToggle == "light"
                              ? AppColorsLight.pure_white
                              : AppColorsDark.pure_white,
                        ),
                      ),
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
                      labelStyle: TextStyle(
                        color: widget.colorToggle == "light"
                            ? AppColorsLight.black
                            : AppColorsDark.black,
                      ),
                      border: OutlineInputBorder(),
                      fillColor: widget.colorToggle == "light"
                          ? AppColorsLight.pure_white
                          : AppColorsDark.light_grey,
                      filled: true,
                    ),
                    style: TextStyle(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.black
                          : AppColorsDark.black,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines:
                        null, // Allows the text field to expand vertically based on content
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                  onPressed: () {
                    _changeRubricWeight(
                        questionIndex, i, -1); // Decrease the weight
                  },
                ),
                Text(
                  '${questions[questionIndex]['rubrics'][i]['weight']} pts',
                  style: TextStyle(
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
                  onPressed: () {
                    _changeRubricWeight(
                        questionIndex, i, 1); // Increase the weight
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: widget.colorToggle == "light"
                        ? AppColorsLight.black
                        : AppColorsDark.black,
                  ),
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

class GenerateExamPopup extends StatefulWidget {
  final String colorToggle;
  final Function(List<Map<String, dynamic>>) updateQuestions;

  const GenerateExamPopup({
    Key? key,
    required this.colorToggle,
    required this.updateQuestions,
  }) : super(key: key);

  @override
  _GenerateExamPopupState createState() => _GenerateExamPopupState();
}

class _GenerateExamPopupState extends State<GenerateExamPopup> {
  List<Uint8List> selectedFilesBytes = [];
  List<String> selectedFilesNames = [];
  bool hasFiles = false;
  bool isLoading = false; // New variable for loading state
  TextEditingController additionalTextController = TextEditingController();

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      final safeFiles = result.files.where((file) => file.bytes != null);

      setState(() {
        // Append new files to the existing list
        selectedFilesBytes
            .addAll(safeFiles.map((file) => file.bytes!).toList());
        selectedFilesNames.addAll(safeFiles.map((file) => file.name).toList());
        hasFiles = selectedFilesBytes.isNotEmpty;

        // Debugging logs
        print('Selected files: ${selectedFilesNames.join(', ')}');
        print('File count: ${selectedFilesBytes.length}');
      });
    } else {
      print('No files selected or file picker error.');
    }
  }

  void _sendDataToAPI() async {
    if (selectedFilesBytes.isEmpty || additionalTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file and enter text.')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Show loading spinner
    });

    var uri =
        Uri.parse('https://create-exam-func.azurewebsites.net/analyze_input');
    var request = http.MultipartRequest('POST', uri);

    request.fields['additionalText'] = additionalTextController.text;

    for (int i = 0; i < selectedFilesBytes.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          selectedFilesBytes[i],
          filename: selectedFilesNames[i],
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        String sanitizedBody = response.body.trim();
        var jsonResponse = jsonDecode(sanitizedBody);

        if (jsonResponse.containsKey('questions')) {
          var newQuestions = (jsonResponse['questions'] as List)
              .map((q) => {
                    'question': TextEditingController(text: q['question']),
                    'weight': q['weight'],
                    'rubrics': (q['rubrics'] as List).map((r) {
                      return {
                        'rubric': TextEditingController(text: r['rubric']),
                        'weight': r['weight'],
                      };
                    }).toList(),
                  })
              .toList();

          widget.updateQuestions(newQuestions);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Questions updated successfully!')),
          );
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to generate questions. Status Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('An error occurred. Check the terminal for details.')),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner
      });
      Navigator.of(context).pop(); // Close the popup
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Large corner radius
          ),
          backgroundColor: widget.colorToggle == "light"
              ? AppColorsLight.pure_white
              : AppColorsDark.pure_white,
          title: Center(
            child: Text(
              'Generate Exam with AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.colorToggle == "light"
                    ? AppColorsLight.black
                    : AppColorsDark.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.colorToggle == "light"
                          ? AppColorsLight.light_grey
                          : AppColorsDark.light_grey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.colorToggle == "light"
                            ? Colors.grey
                            : Colors.grey[600]!,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 40,
                            color: hasFiles ? Colors.green : Colors.black,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Drop or upload images/PDFs',
                            style: TextStyle(
                              color: widget.colorToggle == "light"
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (selectedFilesBytes.isNotEmpty)
                            Column(
                              children: List.generate(selectedFilesBytes.length,
                                  (index) {
                                String fileName = selectedFilesNames[index];
                                bool isImage = ['jpg', 'png'].contains(
                                    fileName.split('.').last.toLowerCase());

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: widget.colorToggle == "light"
                                              ? Colors.grey[300]
                                              : Colors.grey[700],
                                        ),
                                        child: isImage
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.memory(
                                                  selectedFilesBytes[index],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    print(
                                                        'Error rendering image: $fileName');
                                                    return Icon(
                                                      Icons.error,
                                                      size: 24,
                                                      color: Colors.red,
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.picture_as_pdf,
                                                size: 24,
                                                color: widget.colorToggle ==
                                                        "light"
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          fileName.length > 60
                                              ? '${fileName.substring(0, 57)}...'
                                              : fileName,
                                          style: TextStyle(
                                            color: widget.colorToggle == "light"
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Describe in detail how you want your exam to be generated",
                  style: TextStyle(
                    color: widget.colorToggle == "light"
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 500,
                  child: TextField(
                    controller: additionalTextController,
                    decoration: InputDecoration(
                      labelText: 'Instructions',
                      labelStyle: TextStyle(
                        color: widget.colorToggle == "light"
                            ? Colors.black
                            : Colors.white,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Set corner radius to 8
                      ),
                      fillColor: widget.colorToggle == "light"
                          ? Colors.grey[100]
                          : Colors.grey[700],
                      filled: true,
                      alignLabelWithHint: true, // Align label to the top-left
                    ),
                    style: TextStyle(
                      color: widget.colorToggle == "light"
                          ? Colors.black
                          : Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 4,
                    maxLines: 4,
                    textAlign:
                        TextAlign.start, // Align text to the start (left)
                    textAlignVertical:
                        TextAlignVertical.top, // Align text to the top
                  ),
                ),
              ],
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
                  color: widget.colorToggle == "light"
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _sendDataToAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colorToggle == "light"
                    ? AppColorsLight.main_purple
                    : AppColorsDark.main_purple,
              ),
              child: Text(
                'Generate',
                style: TextStyle(
                  color: widget.colorToggle == "light"
                      ? AppColorsLight.pure_white
                      : AppColorsDark.pure_white,
                ),
              ),
            ),
          ],
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
