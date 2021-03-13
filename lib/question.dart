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

import 'package:flutter/foundation.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:json_annotation/json_annotation.dart';
import 'package:uscis_test/prefs.dart';

part 'question.g.dart';

@JsonLiteral('capitals.json', asConst: true)
Map get capitalsData => _$capitalsDataJsonLiteral;

@JsonLiteral('states.json', asConst: true)
Map get _stateAnswersRaw => _$_stateAnswersRawJsonLiteral;

@JsonLiteral('us.json', asConst: true)
Map get _usAnswersRaw => _$_usAnswersRawJsonLiteral;

@JsonLiteral('2008.json', asConst: true)
Map get _2008AnswersRaw => _$_2008AnswersRawJsonLiteral;

class QuestionStorage extends ChangeNotifier {
  final PrefsStorage _prefs;

  final Map<String, Question> _questions = {};
  final Map<String, StateAnswer> _stateAnswers = {};
  final Map<String, UsAnswer> _usAnswers = {};

  List<String> get states {
    var states = _stateAnswers.keys.toList();
    states.sort();
    return states;
  }

  List<String> get districts {
    var districts = ['18th'];
    return districts;
  }

  Map<String, Question> get questions {
    var questions = <String, Question>{};

    _questions.forEach((number, question) {
      if (_prefs.over65Only == true && !question.over65) return;

      List<String> answers;
      List<String> extraAnswers;
      if (question.type == QuestionType.us) {
        answers = _usAnswers[question.recordLookup]?.answers ?? [];
        extraAnswers = _usAnswers[question.recordLookup]?.extraAnswers ?? [];
      } else if (question.type == QuestionType.state) {
        answers = _stateAnswers[_prefs.region]?[question.recordLookup!] ?? [];
        extraAnswers = [];
      } else {
        answers = question.answers;
        extraAnswers = question.extraAnswers;
      }

      questions[number] =
          Question.fromQuestion(question, answers, extraAnswers);
    });

    return questions;
  }

  List<Question> get starredQuestions {
    var starredQuestions = <Question>[];
    for (var question in _prefs.starredList) {
      starredQuestions.add(_questions[question]!);
    }
    return starredQuestions;
  }

  QuestionStorage(this._prefs);

  bool isStarred(final String qnum) => _prefs.isStarred(qnum);

  void toggleStar(final String qnum) {
    _prefs.toggleStar(qnum);
    notifyListeners();
  }

  void initState() {
    _questions.clear();
    _stateAnswers.clear();
    _usAnswers.clear();

    _initStateAnswers();
    _initUsAnswers();
    _initQuestions();
  }

  void _initStateAnswers() {
    _stateAnswersRaw.forEach((key, value) {
      _stateAnswers[key] = StateAnswer.fromJson(key, value);
    });
  }

  void _initUsAnswers() {
    _usAnswersRaw.forEach((key, value) {
      _usAnswers[key] = UsAnswer.fromJson(key, value);
    });
  }

  void _initQuestions() {
    _2008AnswersRaw.forEach((key, value) {
      _questions[key] = Question.fromJson(key, value);
    });
  }
}

@immutable
class StateAnswer {
  final String state;
  final List<String> governor;
  final String capital;
  final List<String> senators;

  List<String> operator [](String field) {
    switch (field) {
      case 'state':
        return [state];
      case 'governor':
        return governor;
      case 'capital':
        return [capital];
      case 'senators':
        return senators;
      default:
        return [];
    }
  }

  StateAnswer.fromJson(this.state, Map<String, dynamic> record)
      : governor = record['governor'].cast<String>(),
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

enum QuestionType {
  none,
  us,
  state,
  representative,
}

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
@immutable
class Question {
  final String number;
  final String question;
  final List<String> answers;
  final List<String> extraAnswers;
  final bool over65;
  final int mustAnswer;
  final QuestionType type;
  final String? recordLookup;

  final _stripParens = RegExp(r'\(.+\)');

  factory Question.fromJson(
    String number,
    Map<String, dynamic> record,
  ) {
    QuestionType type;
    String? recordLookup;
    if (record.containsKey('us_answer')) {
      type = QuestionType.us;
      recordLookup = record['us_answer'];
    } else if (record.containsKey('state_answer')) {
      type = QuestionType.state;
      recordLookup = record['state_answer'];
    } else if (record.containsKey('representative_answer')) {
      type = QuestionType.representative;
      recordLookup = record['representative_answer'];
    } else {
      type = QuestionType.none;
    }

    return Question._(
        number,
        record['question'],
        record['answers'].cast<String>(),
        record['extra_answers']?.cast<String>() ?? <String>[],
        record['over65'] ?? false,
        record['must_answer'] ?? 1,
        type,
        recordLookup);
  }

  Question._(this.number, this.question, this.answers, this.extraAnswers,
      this.over65, this.mustAnswer, this.type, this.recordLookup);

  factory Question.fromQuestion(
      Question orig, List<String> answers, List<String> extraAnswers) {
    return Question._(
      orig.number,
      orig.question,
      answers,
      extraAnswers,
      orig.over65,
      orig.mustAnswer,
      orig.type,
      orig.recordLookup,
    );
  }

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
}
