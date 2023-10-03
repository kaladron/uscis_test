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

import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionchecker.dart';

class LearnLogic extends ChangeNotifier {
  final PrefsStorage _prefs;
  final _random = Random();

  final Map<String, Question> _questions;
  List<String> _randomizedQuestions;
  Set<String> _workingSet;
  Set<String> _rightOnce;
  Set<String> _rightTwice;
  Set<String> _mastered;

  UnmodifiableSetView<String> get workingSet =>
      UnmodifiableSetView<String>(_workingSet);
  UnmodifiableSetView<String> get rightOnce =>
      UnmodifiableSetView<String>(_rightOnce);
  UnmodifiableSetView<String> get rightTwice =>
      UnmodifiableSetView<String>(_rightTwice);
  UnmodifiableSetView<String> get mastered =>
      UnmodifiableSetView<String>(_mastered);

  LearnLogic._(
    final BuildContext context,
    this._questions,
    this._randomizedQuestions,
    this._workingSet,
    this._rightOnce,
    this._rightTwice,
    this._mastered,
    this._prefs,
  ) {
    var next = _nextQuestionfromWorkingSet();
    var question = _questions[next];
    if (question != null) {
      _currentQuestion = next;
      _questionChecker = QuestionChecker(question);
    }
  }

  /// Initialize local question array
  /// Get from prefs, init and persist if it doesn't exist
  factory LearnLogic(final BuildContext context) {
    var prefs = context.read<PrefsStorage>();

    // Doing this inline confuses the compiler, it thinks the return type is Object
    generateRandomizedQuestions() {
      var tmp = context.read<QuestionStorage>().questions.keys.toList();
      tmp.shuffle();
      prefs.randomizedQuestions = tmp;
      return tmp;
    }

    var randomizedQuestions =
        prefs.randomizedQuestions ?? generateRandomizedQuestions();

    debugPrint('Questions: ${randomizedQuestions.toString()}');

    generateWorkingSet() {
      var tmp = <String>{};
      for (var _ in Iterable<int>.generate(10)) {
        tmp.add(randomizedQuestions.removeLast());
      }
      prefs.randomizedQuestions = randomizedQuestions;
      prefs.workingSet = tmp;
      return tmp;
    }

    // TODO(jeffbailey): Add integrity checks to these - no dupes, right number
    // in working set, etc.

    var workingSet = prefs.workingSet ?? generateWorkingSet();

    debugPrint('Working Set: ${workingSet.toString()}');

    var rightOnce = prefs.rightOnce;
    debugPrint('Right Once: ${rightOnce.toString()}');

    var rightTwice = prefs.rightTwice;
    debugPrint('Right Twice: ${rightTwice.toString()}');

    var mastered = prefs.mastered;
    debugPrint('Mastered: ${mastered.toString()}');

    var questions =
        Map<String, Question>.from(context.read<QuestionStorage>().questions);

    return LearnLogic._(context, questions, randomizedQuestions, workingSet,
        rightOnce, rightTwice, mastered, prefs);
  }

  double get progress => _mastered.length / _questions.length;

  Question get question => _questions[_currentQuestion]!;

  late QuestionChecker _questionChecker;

  String? _currentQuestion;

  String _nextQuestionfromWorkingSet() =>
      _questions[_workingSet.toList()[_random.nextInt(_workingSet.length)]]!
          .number;

  void nextQuestion() {
    _currentQuestion = _nextQuestionfromWorkingSet();

    _questionChecker = QuestionChecker(_questions[_currentQuestion]!);
    notifyListeners();
  }

  // Used for any time that a right answer shouldn't count as "Right",
  // such as if "show answer" is displayed, or a duplicate answer, etc.
  void cancelQuestion() {
    _questionChecker.cancelled = true;
    if (_rightOnce.contains(_currentQuestion)) {
      _rightOnce.remove(_currentQuestion);
      _prefs.rightOnce = _rightOnce;
    }
    if (_rightTwice.contains(_currentQuestion)) {
      _rightTwice.remove(_currentQuestion);
      _prefs.rightTwice = _rightTwice;
    }
  }

  QuestionStatus checkAnswer(final String origAnswer) {
    var status = _questionChecker.checkAnswer(origAnswer);
    debugPrint(status.toString());

    // Cope with Dart's null handling limitations
    var currentQuestion = _currentQuestion;
    if (currentQuestion == null) {
      throw Exception('Current Question is somehow null!');
    }

    switch (status) {
      case QuestionStatus.correctOnce:
        if (_rightTwice.contains(currentQuestion)) {
          _rightTwice.remove(currentQuestion);
          _mastered.add(currentQuestion);
          _workingSet.remove(currentQuestion);

          if (_randomizedQuestions.isNotEmpty) {
            var newQuestion = _randomizedQuestions.removeLast();
            debugPrint('Adding: $newQuestion');
            _workingSet.add(newQuestion);
          }
          _prefs.randomizedQuestions = _randomizedQuestions;
          _prefs.rightTwice = _rightTwice;
          _prefs.mastered = _mastered;
          _prefs.workingSet = _workingSet;

          return QuestionStatus.correctThrice;
        }

        if (_rightOnce.contains(currentQuestion)) {
          _rightOnce.remove(currentQuestion);
          _rightTwice.add(currentQuestion);
          _prefs.rightOnce = _rightOnce;
          _prefs.rightTwice = _rightTwice;
          return QuestionStatus.correctTwice;
        }

        _rightOnce.add(currentQuestion);
        _prefs.rightOnce = _rightOnce;
        return QuestionStatus.correctOnce;
      case QuestionStatus.incorrect:
        cancelQuestion();
        return status;
      default:
        return status;
    }
  }
}
