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
import 'package:uscis_test/prefs.dart';

class QuestionStorage {
  final PrefsStorage _prefs;

  List<Question> _questions;

  List<Question> get questions {
    if (!_prefs.over65Only) {
      return _questions;
    }
    List<Question> over65Questions = [];
    for (var question in _questions) {
      if (question.over65) {
        over65Questions.add(question);
      }
    }
    return over65Questions;
  }

  bool isStarred(int qnum) {
    return _prefs.isStarred(qnum);
  }

  void toggle(int qnum) {
    _prefs.toggle(qnum);
  }

  QuestionStorage(this._prefs);

  // TODO(jeffbailey):
  // https://uscis.gov/citizenship/testupdates to update:
  //      "question": "What is the name of the President of the United States now?",
  //      "question": "What is the name of the Vice President of the United States now?",
  //      "question": "How many justices are on the Supreme Court?",
  //      "question": "Who is the Chief Justice of the United States now?",
  //      "question": "What is the political party of the President now?",
  //      "question": "What is the name of the Speaker of the House of Representatives now?",

  // https://www.usa.gov/states-and-territories to update:
  //      "question": "Who is one of your state’s U.S. Senators now?",
  //      "question": "Name your U.S. Representative.",
  //      "question": "Who is the Governor of your state now?",
  //      "question": "What is the capital of your state?",

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
    List<String> strippedAnswers = [];
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
