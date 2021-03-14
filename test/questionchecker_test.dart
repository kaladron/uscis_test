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

import 'dart:convert';

import 'package:test/test.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionchecker.dart';

void main() {
  group('Question Checker', () {
    const contents = '''{
      "19": {
          "question": "We elect a U.S. Senator for how many years?",
          "answers": [
              "six (6)"
          ],
          "extra_answers": [
              "6 (years)"
          ]
      },
      "61": {
          "question": "Why did the colonists fight the British?",
          "answers": [
              "because of high taxes (taxation without representation)",
              "because the British army stayed in their houses (boarding, quartering)",
              "because they didn’t have self-government"
          ]
      },
        "95": {
        "question": "Where is the Statue of Liberty?",
        "answers": [
            "New York (Harbor)",
            "Liberty Island",
            "[Also acceptable are New Jersey, near New York City, and on the Hudson (River).]"
        ],
        "extra_answers": [
            "New Jersey",
            "near New York City",
            "on the Hudson (River)"
        ],
        "over65": true
    }}''';

    final Map<String, dynamic> data = jsonDecode(contents);

    final questions = <String, Question>{};
    data.forEach((key, value) {
      questions[key] = Question.fromJson(key, value);
    });

    test('Test without parens', () {
      final checker = QuestionChecker(questions['95']!);
      expect(checker.checkAnswer('new york'), QuestionStatus.correctOnce);
    });

    test('Test with parens', () {
      final checker = QuestionChecker(questions['95']!);
      expect(
          checker.checkAnswer('new york harbor'), QuestionStatus.correctOnce);
    });

    test('Test second answer', () {
      final checker = QuestionChecker(questions['95']!);
      expect(checker.checkAnswer('liberty island'), QuestionStatus.correctOnce);
    });

    test('Test extra answer', () {
      final checker = QuestionChecker(questions['95']!);
      expect(checker.checkAnswer('new jersey'), QuestionStatus.correctOnce);
    });

    test('Test extra answer without parens', () {
      final checker = QuestionChecker(questions['95']!);
      expect(checker.checkAnswer('on the hudson'), QuestionStatus.correctOnce);
    });

    test('Test extra answer with parens', () {
      final checker = QuestionChecker(questions['95']!);
      expect(checker.checkAnswer('hudson river'), QuestionStatus.correctOnce);
    });

    test('Test answer with hyphen', () {
      final checker = QuestionChecker(questions['61']!);
      expect(checker.checkAnswer("because they didn't have self-government"),
          QuestionStatus.correctOnce);
    });
    test('Test wrong answer', () {
      final checker = QuestionChecker(questions['95']!);
      expect(checker.checkAnswer('san fransisco'), QuestionStatus.incorrect);
    });
    test('Test fuzzy answer', () {
      final checker = QuestionChecker(questions['19']!);
      expect(checker.checkAnswer('sex'), QuestionStatus.correctOnce);
    });
  });
}
