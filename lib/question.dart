import 'dart:convert';

import 'package:flutter/services.dart';

class QuestionStorage {
  List<Question> _questions;

  List<Question> get questions => _questions;

  QuestionStorage() {
    _readFile();
  }

  Future<List<Question>> _readFile() async {
//    try {
    var contents = await rootBundle.loadString('2008.json');
    var data = jsonDecode(contents);
    _questions = [];
    for (Map i in data) {
      _questions.add(Question.fromJson(i));
    }
    return _questions;
//    } catch (e) {
//      // TODO(jeffbailey): Better error handling.
//      return e.toString();
//    }
  }
}

class Question {
  final int number;
  final String question;
  final List<String> answers;
  final bool over65;
  final int mustAnswer;

  Question.fromJson(Map<String, dynamic> json)
      : number = json['number'],
        question = json['question'],
        answers = json['answers'].cast<String>(),
        over65 = json.containsKey('over65') ? json['over65'] : false,
        mustAnswer = json.containsKey('must_answer') ? json['must_answer'] : 1;
}
