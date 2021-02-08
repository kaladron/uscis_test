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
  final _random = Random();

  final Map<int, Question> _questions;
  late List<int> _randomizedQuestions;
  late List<int> _workingSet;
  late Set<int> _rightOnce;
  late Set<int> _rightTwice;
  late Set<int> _mastered;

  LearnLogic(final BuildContext _context)
      : _questions = Map<int, Question>.from(
            _context.read<QuestionStorage>().questions) {
    // Initialize local question array
    //   Get from prefs, init and persist if it doesn't exist

    // Doing this inline confuses the compiler, it thinks the return type is Object
    var generateRandomizedQuestions = () {
      List<int> tmp = _context.read<QuestionStorage>().questions.keys.toList();
      tmp.shuffle();
      return tmp;
    };

    _randomizedQuestions = _context.read<PrefsStorage>().randomizedQuestions ??
        generateRandomizedQuestions();

    var generateWorkingSet = () {
      List<int> tmp = [];
      for (var _ in Iterable<int>.generate(10)) {
        tmp.add(_randomizedQuestions.removeLast());
      }
      return tmp;
    };

    _workingSet =
        _context.read<PrefsStorage>().workingSet ?? generateWorkingSet();

    _rightOnce = _context.read<PrefsStorage>().rightOnce;
    _rightTwice = _context.read<PrefsStorage>().rightTwice;
    _mastered = _context.read<PrefsStorage>().mastered;

    _questionChecker = QuestionChecker(_questions[_workingSet[_cursor]]!);
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
          return QuestionStatus.correctThrice;
        }

        if (_rightOnce.contains(_workingSet[_cursor])) {
          _rightOnce.remove(_workingSet[_cursor]);
          _rightTwice.add(_workingSet[_cursor]);
          return QuestionStatus.correctTwice;
        }

        _rightOnce.add(_workingSet[_cursor]);
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
