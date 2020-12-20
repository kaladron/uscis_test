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
        '${context.watch<QuestionPicker>().question}',
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
    context.read<QuestionPicker>().getQuestion(1);
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

/// Mix-in [DiagnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
// ignore: prefer_mixin
class QuestionPicker with ChangeNotifier, DiagnosticableTreeMixin {
  String _question = "foo bar baz";

  String get question => _question;

  int _counter = 0;

  final QuestionStorage storage = QuestionStorage();

  QuestionPicker() {
    _init();
  }

  Future _init() async {
    storage.readFile();
  }

  void getQuestion(int _) {
    _counter++;
    _question = storage.questions[_counter].question;
    notifyListeners();
  }

  /// Makes `QuestionPicker` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('question', question));
  }
}
