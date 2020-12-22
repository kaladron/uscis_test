// Title bar with question number, sandwich, heart to save question
// If enabled, text of question
// Button to trigger listening response
// Bottom bar with Home, Prev, Next

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uscis_test/question.dart';
import 'package:provider/provider.dart';

import 'dart:async';

class QuestionScreen extends StatefulWidget {
  static const routeName = '/question';
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Question"),
      ),
      body: QuestionWidget(
        '${context.watch<QuestionPicker>().question.question}',
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
        onTap: _doAThing,
      ),
    );
  }

  void _doAThing(int x) {
    context.read<QuestionPicker>().getQuestion(x);
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

class QuestionPicker with ChangeNotifier {
  Question get question => _storage.questions[_cursor];

  int _cursor = 0;

  final QuestionStorage _storage;

  QuestionPicker(this._storage) {
    _init();
  }

  Future _init() async {
    await _storage.readFile();
  }

  // TODO(jeffbailey): Bounds check these.
  void prevQuestion() {
    _cursor--;
    notifyListeners();
  }

  void nextQuestion() {
    _cursor++;
    notifyListeners();
  }

  void getQuestion(int cursor) {
    _cursor = cursor;
    notifyListeners();
  }
}
