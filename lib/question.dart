// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
  final List<String> extraAnswers;
  final bool over65;
  final int mustAnswer;

  // TODO(jeffbailey): Expand this for all the optional parens answers.
  List<String> get allAnswers => [...answers, ...?extraAnswers];

  Question.fromJson(Map<String, dynamic> json)
      : number = json['number'],
        question = json['question'],
        answers = json['answers'].cast<String>(),
        extraAnswers = json.containsKey('extra_answers')
            ? json['extra_answers'].cast<String>()
            : [""],
        over65 = json.containsKey('over65') ? json['over65'] : false,
        mustAnswer = json.containsKey('must_answer') ? json['must_answer'] : 1;
}
