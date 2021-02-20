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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uscis_test/prefs.dart';

class QuestionStorage extends ChangeNotifier {
  final PrefsStorage _prefs;

  final Map<int, Question> _questions = {};
  final Map<String, StateAnswer> _stateAnswers = {};
  final Map<String, UsAnswer> _usAnswers = {};

  List<String> get states {
    var states = _stateAnswers.keys.toList();
    states.sort();
    return states;
  }

  Map<int, Question> get questions {
    if (!_prefs.over65Only) {
      return _questions;
    }
    var over65Questions = <int, Question>{};
    _questions.forEach((number, question) {
      if (question.over65) {
        over65Questions[number] = question;
      }
    });
    return over65Questions;
  }

  List<Question> get starredQuestions {
    var starredQuestions = <Question>[];
    for (var question in _prefs.starredList) {
      starredQuestions.add(_questions[int.parse(question)]!);
    }
    return starredQuestions;
  }

  bool isStarred(final int qnum) => _prefs.isStarred(qnum);

  void toggle(final int qnum) {
    _prefs.toggle(qnum);
    notifyListeners();
  }

  QuestionStorage(this._prefs);

  // TODO(jeffbailey): Finish state-specific questions.

  Future<void> initState() async {
    await initStateAnswers();
    await initUsAnswers();
    await initQuestions();
  }

  Future<void> initStateAnswers() async {
    var contents = await rootBundle.loadString('states.json');
    Map<String, dynamic> data = jsonDecode(contents);
    data.forEach((key, value) {
      _stateAnswers[key] = StateAnswer.fromJson(key, value);
    });
  }

  Future<void> initUsAnswers() async {
    var contents = await rootBundle.loadString('us.json');
    Map<String, dynamic> data = jsonDecode(contents);
    data.forEach((key, value) {
      _usAnswers[key] = (UsAnswer.fromJson(key, value));
    });
  }

  Future<void> initQuestions() async {
    var contents = await rootBundle.loadString('2008.json');
    var data = jsonDecode(contents);
    _questions.clear();
    for (Map<String, dynamic> i in data) {
      var q = Question.fromJson(i, _usAnswers);
      _questions[q.number] = q;
    }
  }
}

@immutable
class StateAnswer {
  final String state;
  final String governor;
  final String capital;
  final List<String> senators;

  StateAnswer.fromJson(this.state, Map<String, dynamic> record)
      : governor = record['governor'],
        capital = record['capital'],
        senators = record['senators'].cast<String>();
}

@immutable
class UsAnswer {
  final String key;
  final List<String> answers;
  final List<String> extraAnswers;

  UsAnswer.fromJson(this.key, Map<String, dynamic> record)
      : answers = record['answers'].cast<String>(),
        extraAnswers = record['extra_answers']?.cast<String>() ?? [];
}

@immutable
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
    var strippedAnswers = <String>[];
    var strippedExtraAnswers = <String>[];

    for (var answer in answers) {
      if (answer.contains('(')) {
        var strippedAnswer = answer.replaceAll(_stripParens, '');
        strippedAnswers.add(strippedAnswer);
      }
    }

    for (var answer in extraAnswers) {
      if (answer.contains('(')) {
        var strippedAnswer = answer.replaceAll(_stripParens, '');
        strippedExtraAnswers.add(strippedAnswer);
      }
    }

    return [
      ...answers,
      if (extraAnswers.isNotEmpty) ...extraAnswers,
      if (strippedAnswers.isNotEmpty) ...strippedAnswers,
      if (strippedExtraAnswers.isNotEmpty) ...strippedExtraAnswers,
    ];
  }

  Question.fromJson(
      final Map<String, dynamic> json, final Map<String, UsAnswer> usAnswers)
      : number = json['number'],
        question = json['question'],
        answers = (json['us_answer'] == null)
            ? json['answers'].cast<String>()
            : usAnswers[json['us_answer']]!.answers,
        extraAnswers = (json['us_answer'] == null)
            ? json.containsKey('extra_answers')
                ? json['extra_answers'].cast<String>()
                : []
            : usAnswers[json['us_answer']]!.extraAnswers,
        over65 = json.containsKey('over65') ? json['over65'] : false,
        mustAnswer = json.containsKey('must_answer') ? json['must_answer'] : 1;
}
