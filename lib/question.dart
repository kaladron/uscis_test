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
import 'package:json_annotation/json_annotation.dart';
import 'package:uscis_test/prefs.dart';

part 'question.g.dart';

@JsonLiteral('capitals.json', asConst: true)
Map get _capitalsAnswersRaw => _$_capitalsAnswersRawJsonLiteral;

@JsonLiteral('us.json', asConst: true)
Map get _usAnswersRaw => _$_usAnswersRawJsonLiteral;

@JsonLiteral('2008.json', asConst: true)
Map get _2008AnswersRaw => _$_2008AnswersRawJsonLiteral;

@JsonLiteral('representatives.json', asConst: true)
Map<String, List<Map<String, String>>> get _representativesAnswersRaw =>
    _$_representativesAnswersRawJsonLiteral;

@JsonLiteral('senators.json', asConst: true)
Map<String, List<Map<String, String>>> get _senatorsAnswersRaw =>
    _$_senatorsAnswersRawJsonLiteral;

class QuestionStorage extends ChangeNotifier {
  final PrefsStorage _prefs;

  final Map<String, Question> _questions = {};
  final Map<String, UsAnswer> _usAnswers = {};
  final Map<String, String> _capitals = {};
  final Map<String, List<ElectedPerson>> _senators = {};
  final Map<String, Map<String, ElectedPerson>> _representatives = {};

  List<String> get states {
    var states = _capitals.keys.toList();
    states.sort();
    return states;
  }

  List<String> get districts {
    var districts = _representatives[_prefs.region]?.keys.toList() ?? [];
    return districts;
  }

  Map<String, Question> get questions {
    var questions = <String, Question>{};

    _questions.forEach((number, question) {
      if (_prefs.over65Only == true && !question.over65) return;

      List<String> answers;
      List<String> extraAnswers;
      switch (question.type) {
        case QuestionType.us:
          answers = _usAnswers[question.recordLookup]?.answers ?? [];
          extraAnswers = _usAnswers[question.recordLookup]?.extraAnswers ?? [];
          break;
        case QuestionType.capital:
          answers = [_capitals[_prefs.region] ?? ''];
          extraAnswers = [];
          break;
        case QuestionType.senator:
          answers = [];
          for (var senator in _senators[_prefs.region] ?? []) {
            answers.addAll(senator.answers);
          }
          extraAnswers = [];
          break;
        case QuestionType.representative:
          answers =
              _representatives[_prefs.region]?[_prefs.district]?.answers ??
                  [''];
          extraAnswers = [];
          break;
        case QuestionType.governor:
          answers = ['Gavin Newsom', 'Newsom'];
          extraAnswers = [];
          break;
        default:
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
    _usAnswers.clear();
    _usAnswersRaw.forEach((key, value) {
      _usAnswers[key] = UsAnswer.fromJson(key, value);
    });

    _questions.clear();
    _2008AnswersRaw.forEach((key, value) {
      _questions[key] = Question.fromJson(key, value);
    });

    _capitals.clear();
    _capitalsAnswersRaw.forEach((key, value) {
      _capitals[key] = value;
    });

    _representatives.clear();
    _representativesAnswersRaw.forEach((key, value) {
      _representatives[key] ??= {};
      for (var districtrep in value) {
        _representatives[key]![districtrep['district']!] =
            ElectedPerson.fromJson(districtrep);
      }
    });

    _senators.clear();
    _senatorsAnswersRaw.forEach((key, value) {
      _senators[key] ??= [];
      for (var senator in value) {
        _senators[key]!.add(ElectedPerson.fromJson(senator));
      }
    });
  }
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
class ElectedPerson {
  final String firstName;
  final String lastName;

  List<String> get answers => ['$firstName $lastName', lastName];

  ElectedPerson.fromJson(Map<String, dynamic> record)
      : firstName = record['first_name'],
        lastName = record['last_name'];

  @override
  String toString() {
    print('$firstName $lastName');
    return super.toString();
  }
}

enum QuestionType {
  none,
  capital,
  governor,
  representative,
  senator,
  us,
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
  final bool onlyExtraAnswers;
  final QuestionType type;
  final String? recordLookup;

  final _stripParens = RegExp(r'\(.+\)');

  factory Question.fromJson(
    String number,
    Map<String, dynamic> record,
  ) {
    var type = QuestionType.none;

    String? recordLookup;
    if (record.containsKey('us_answer')) {
      type = QuestionType.us;
      recordLookup = record['us_answer'];
    }

    String? outsideRecord = record['outside_record'];

    switch (outsideRecord) {
      case 'capital':
        type = QuestionType.capital;
        break;
      case 'representative':
        type = QuestionType.representative;
        break;
      case 'senator':
        type = QuestionType.senator;
        break;
      case 'governor':
        type = QuestionType.governor;
        break;
    }

    return Question._(
        number,
        record['question'],
        record['answers'].cast<String>(),
        record['extra_answers']?.cast<String>() ?? <String>[],
        record['over65'] ?? false,
        record['must_answer'] ?? 1,
        record['only_extra_answers'] ?? false,
        type,
        recordLookup);
  }

  Question._(
      this.number,
      this.question,
      this.answers,
      this.extraAnswers,
      this.over65,
      this.mustAnswer,
      this.onlyExtraAnswers,
      this.type,
      this.recordLookup);

  factory Question.fromQuestion(
      Question orig, List<String> answers, List<String> extraAnswers) {
    return Question._(
      orig.number,
      orig.question,
      answers,
      extraAnswers,
      orig.over65,
      orig.mustAnswer,
      orig.onlyExtraAnswers,
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
      if (!onlyExtraAnswers) ...answers,
      if (extraAnswers.isNotEmpty) ...extraAnswers,
      if (!onlyExtraAnswers)
        if (strippedAnswers.isNotEmpty) ...strippedAnswers,
      if (strippedExtraAnswers.isNotEmpty) ...strippedExtraAnswers,
    ];
  }
}
