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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionchecker.dart';

class LearnLogic extends ChangeNotifier {
  final PrefsStorage _prefs;
  final _random = Random();

  final Map<int, Question> _questions;
  List<int> _randomizedQuestions;
  List<int> _workingSet;
  Set<int> _rightOnce;
  Set<int> _rightTwice;
  Set<int> _mastered;

  List<int> get workingSet => _workingSet;
  Set<int> get rightOnce => _rightOnce;
  Set<int> get rightTwice => _rightTwice;
  Set<int> get mastered => _mastered;

  LearnLogic._(
      final BuildContext _context,
      this._questions,
      this._randomizedQuestions,
      this._workingSet,
      this._rightOnce,
      this._rightTwice,
      this._mastered)
      : _prefs = _context.read<PrefsStorage>() {
    _questionChecker = QuestionChecker(_questions[_workingSet[_cursor]]!);
  }

  /// Initialize local question array
  /// Get from prefs, init and persist if it doesn't exist
  factory LearnLogic(final BuildContext context) {
    var prefs = context.read<PrefsStorage>();

    // Doing this inline confuses the compiler, it thinks the return type is Object
    var generateRandomizedQuestions = () {
      var tmp = context.read<QuestionStorage>().questions.keys.toList();
      tmp.shuffle();
      prefs.randomizedQuestions = tmp;
      return tmp;
    };

    var randomizedQuestions =
        prefs.randomizedQuestions ?? generateRandomizedQuestions();

    print('Questions: ${randomizedQuestions.toString()}');

    var generateWorkingSet = () {
      var tmp = <int>[];
      for (var _ in Iterable<int>.generate(10)) {
        tmp.add(randomizedQuestions.removeLast());
      }
      prefs.workingSet = tmp;
      return tmp;
    };

    var workingSet = prefs.workingSet ?? generateWorkingSet();

    print('Working Set: ${workingSet.toString()}');

    var rightOnce = prefs.rightOnce;
    print('Right Once: ${rightOnce.toString()}');

    var rightTwice = prefs.rightTwice;
    print('Right Twice: ${rightTwice.toString()}');

    var mastered = prefs.mastered;
    print('Mastered: ${mastered.toString()}');

    var questions =
        Map<int, Question>.from(context.read<QuestionStorage>().questions);

    return LearnLogic._(context, questions, randomizedQuestions, workingSet,
        rightOnce, rightTwice, mastered);
  }

  double get progress => _mastered.length / _questions.length;

  Question get question => _questions[_workingSet[_cursor]]!;

  late QuestionChecker _questionChecker;

  int _cursor = 0;

  void nextQuestion() {
    _cursor = _random.nextInt(_workingSet.length);
    _questionChecker = QuestionChecker(_questions[_workingSet[_cursor]]!);
    notifyListeners();
  }

  // Used for any time that a right answer shouldn't count as "Right",
  // such as if "show answer" is displayed, or a duplicate answer, etc.
  void cancelQuestion() {
    _questionChecker.cancelled = true;
    if (_rightOnce.contains(_workingSet[_cursor])) {
      _rightOnce.remove(_workingSet[_cursor]);
      _prefs.rightOnce = _rightOnce;
    }
    if (_rightTwice.contains(_workingSet[_cursor])) {
      _rightTwice.remove(_workingSet[_cursor]);
      _prefs.rightTwice = _rightTwice;
    }
  }

  // TODO(jeffbailey): Handle more than one answer needed.
  QuestionStatus checkAnswer(final String origAnswer) {
    var status = _questionChecker.checkAnswer(origAnswer);
    print(status.toString());

    switch (status) {
      case QuestionStatus.correctOnce:
        if (_rightTwice.contains(_workingSet[_cursor])) {
          _rightTwice.remove(_workingSet[_cursor]);
          _mastered.add(_workingSet[_cursor]);
          _workingSet.removeAt(_cursor);
          if (_questions.isNotEmpty) {
            _workingSet.add(_randomizedQuestions.removeLast());
          }
          _prefs.rightTwice = _rightTwice;
          _prefs.mastered = _mastered;
          _prefs.workingSet = _workingSet;

          return QuestionStatus.correctThrice;
        }

        if (_rightOnce.contains(_workingSet[_cursor])) {
          _rightOnce.remove(_workingSet[_cursor]);
          _rightTwice.add(_workingSet[_cursor]);
          _prefs.rightOnce = _rightOnce;
          _prefs.rightTwice = _rightTwice;
          return QuestionStatus.correctTwice;
        }

        _rightOnce.add(_workingSet[_cursor]);
        _prefs.rightOnce = _rightOnce;
        return QuestionStatus.correctOnce;
      case QuestionStatus.incorrect:
        cancelQuestion();
        return status;
      case QuestionStatus.duplicate:
        return QuestionStatus.correctOnce;
      case QuestionStatus.moreNeeded:
        return QuestionStatus.correctOnce;
      default:
        return status;
    }
  }
}
