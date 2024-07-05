import 'package:flutter/material.dart';

class ProfessorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professor Screen'),
      ),
      body: Center(
        child: Text(
          'Professor',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
