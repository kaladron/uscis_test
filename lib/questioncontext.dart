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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionchecker.dart';

class QuestionContext extends ChangeNotifier {
  final BuildContext _context;

  QuestionContext(this._context, this._cursor);

  Question get question => _context.read<QuestionStorage>().questions[_cursor];

  int _cursor;

  void prevQuestion() {
    setQuestion(_cursor - 1);
  }

  void nextQuestion() {
    setQuestion(_cursor + 1);
  }

  void setQuestion(int cursor) {
    if (cursor < 0) return;
    if (_context.read<QuestionStorage>().questions.length < (cursor + 1)) {
      return;
    }
    _cursor = cursor;
    notifyListeners();
  }

  bool checkAnswer(String origAnswer) {
    return _context.read<QuestionChecker>().checkAnswer(question, origAnswer);
  }
}
