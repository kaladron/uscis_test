import 'dart:convert';

import 'package:flutter/services.dart';

class QuestionStorage {
  Future<String> readFile() async {
//    try {
    var contents = await rootBundle.loadString('2008.json');
    var data = jsonDecode(contents);
    List<Question> questions = [];
    for (Map i in data) {
      questions.add(Question.fromJson(i));
    }
    return questions[0].question;
//    } catch (e) {
//      // TODO(jeffbailey): Better error handling.
//      return e.toString();
//    }
  }
}

List<Question> moduleQuestionFromJson(String str) =>
    List<Question>.from(json.decode(str).map((x) => Question.fromJson(x)));

class Question {
  final int number;
  final String question;
  // answers
  // final bool over65;
  // final int must_answer;

  Question.fromJson(Map<String, dynamic> json)
      : number = json['number'],
        question = json['question'];
}
