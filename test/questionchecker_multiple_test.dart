// Copyright 2021 Google LLC
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

// @dart=2.9

import 'dart:convert';

import 'package:test/test.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionchecker.dart';

void main() {
  group('Question Checker', () {
    const contents = '''{
        "9": {
        "question": "What are two rights in the Declaration of Independence?",
        "answers": [
            "life",
            "liberty",
            "pursuit of happiness"
        ],
        "must_answer": 2
    }}''';

    final Map<String, dynamic> data = jsonDecode(contents);

    final questions = <String, Question>{};
    data.forEach((key, value) {
      questions[key] = Question.fromJson(key, value);
    });

    test('Test One Answer of Many', () {
      final checker = QuestionChecker(questions['9']);
      expect(checker.checkAnswer('life'), QuestionStatus.moreNeeded);
    });
  });
}
