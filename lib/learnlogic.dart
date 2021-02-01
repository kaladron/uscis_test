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
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionchecker.dart';

class LearnLogic extends ChangeNotifier {
  final _random = Random();

  List<Question> _questions;
  List<Question> _workingSet = [];

  int mastered = 0;

  LearnLogic(BuildContext _context)
      : _questions =
            List<Question>.from(_context.read<QuestionStorage>().questions) {
    // Initialize local question array
    //   Get from prefs, init and persist if it doesn't exist

    _questions.shuffle();
    for (var _ in Iterable<int>.generate(10)) {
      _workingSet.add(_questions.removeLast());
    }

    _questionChecker = QuestionChecker(_workingSet[_cursor]);
  }

  double get progress => mastered / _questions.length;

  Question get question => _workingSet[_cursor];

  late QuestionChecker _questionChecker;

  int _cursor = 0;

  void nextQuestion() {
    _cursor = _random.nextInt(_workingSet.length);
    _questionChecker = QuestionChecker(_workingSet[_cursor]);
    notifyListeners();
  }

  // TODO(jeffbailey): Handle more than one answer needed.
  QuestionStatus checkAnswer(String origAnswer) {
    var status = _questionChecker.checkAnswer(origAnswer);

    if (status == QuestionStatus.correct) {
      mastered++;
      _workingSet.removeAt(_cursor);
      if (_questions.isNotEmpty) {
        _workingSet.add(_questions.removeLast());
      }

      nextQuestion();
      return QuestionStatus.correct;
    }

    if (status == QuestionStatus.cancelled) return QuestionStatus.correct;
    if (status == QuestionStatus.duplicate) return QuestionStatus.correct;
    if (status == QuestionStatus.moreNeeded) return QuestionStatus.correct;

    return status;
  }
}
