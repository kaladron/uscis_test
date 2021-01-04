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

  Future<void> initState() async {
//    try {
    var contents = await rootBundle.loadString('2008.json');
    var data = jsonDecode(contents);
    _questions = [];
    for (Map i in data) {
      _questions.add(Question.fromJson(i));
    }
//    } catch (e) {
//      // TODO(jeffbailey): Better error handling.
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

  final _stripParens = RegExp(r'\(.+\)');

  /// The Answer set includes:
  ///  * The official answers in the book.
  ///  * "alternative phrasing of the correct answer"
  ///    see: https://www.uscis.gov/sites/default/files/document/guides/Test_Scoring_Guidelines.pdf
  ///  * Answers with the bits in parens filtered out.
  ///
  /// There is no guide to alternative phrasings, but it's used to convert words
  /// into numbers, allow "fourth of July" in addition to "July 4", etc.
  ///
  /// These are split into these groups so that only the official answers
  /// are ever shown to the user.  That is what they should be studying from.
  List<String> get allAnswers {
    var strippedAnswers = List<String>();
    for (var answer in answers) {
      if (answer.contains('(')) {
        var strippedAnswer = answer.replaceAll(_stripParens, '');
        strippedAnswers.add(strippedAnswer);
      }
    }
    return [
      ...answers,
      if (extraAnswers.isNotEmpty) ...extraAnswers,
      if (strippedAnswers.isNotEmpty) ...strippedAnswers
    ];
  }

  Question.fromJson(Map<String, dynamic> json)
      : number = json['number'],
        question = json['question'],
        answers = json['answers'].cast<String>(),
        extraAnswers = json.containsKey('extra_answers')
            ? json['extra_answers'].cast<String>()
            : [],
        over65 = json.containsKey('over65') ? json['over65'] : false,
        mustAnswer = json.containsKey('must_answer') ? json['must_answer'] : 1;
}
