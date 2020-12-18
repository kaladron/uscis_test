// Title bar with question number, sandwich, heart to save question
// If enabled, text of question
// Button to trigger listening response
// Bottom bar with Home, Prev, Next

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionStorage {
  Future<String> readFile() async {
    try {
      var contents = await rootBundle.loadString('2008.json');

      return contents;
    } catch (e) {
      return e.toString();
    }
  }
}

class QuestionScreen extends StatefulWidget {
  static const routeName = '/question';
  final QuestionStorage storage = QuestionStorage();
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  String _questionText = "ooga";

  void initState() {
    super.initState();
    widget.storage.readFile().then((String value) {
      setState(() {
        _questionText = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Question"),
      ),
      body: QuestionWidget(
        _questionText,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.skip_previous),
            label: 'Previous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.skip_next),
            label: 'Next',
          ),
        ],
      ),
    );
  }
}

class QuestionWidget extends StatefulWidget {
  final String questionText;
  const QuestionWidget(this.questionText);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.questionText);
  }
}
