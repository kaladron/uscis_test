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

import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/stemmer/SnowballStemmer.dart';
import 'package:uscis_test/stemmer/stopwords.dart';

enum QuestionStatus {
  cancelled,
  correctOnce,
  correctTwice,
  correctThrice,
  duplicate,
  incorrect,
  moreNeeded,
}

@visibleForTesting
class AnswerChain {
  final Map<String, AnswerChain> _next = {};
  bool _okEnd = false;

  @override
  String toString({int indentval = 0}) {
    var output = '';
    if (_okEnd) output += ' END';
    _next.forEach((key, value) {
      output += '\n' + ' ' * indentval + key;
      output += value.toString(indentval: indentval + 2);
    });
    return output;
  }

  void add(final List<String> words) {
    if (words.isEmpty) {
      _okEnd = true;
      return;
    }

    var nextChain = _next[words.first];

    if (nextChain == null) {
      nextChain = AnswerChain();
      _next[words.first] = nextChain;
    }

    nextChain.add(words.sublist(1));
  }

  List<String>? match(final List<String> words, [List<String>? answerWords]) {
    answerWords ??= [];
    if (words.isEmpty && _okEnd) {
      return answerWords;
    }

    if (words.isEmpty) {
      return null;
    }

    // Is our next word in the list?
    var d = Levenshtein();
    AnswerChain? nextChain;
    for (var key in _next.keys) {
      if (d.distance(key, words.first) <= 1) {
        nextChain = _next[key];
        break;
      }
    }
    if (nextChain == null) {
      // Nope!
      return null;
    }

    answerWords.add(words.first);
    return nextChain.match(words.sublist(1), answerWords);
  }
}

class QuestionChecker {
  final Question _question;

  final _answers = AnswerChain();

  QuestionChecker(this._question) {
    for (var answer in _question.allAnswers) {
      var keyTokens = getTokens(answer);
      _answers.add(keyTokens);
    }
  }

  final _stemmer = SnowballStemmer();

  final List<List<String>> _rightAnswers = [];

  bool cancelled = false;

  // I don't love reinitializing this per question.
  final _stripPunctuation = RegExp(r"[^\w\s']+");
  final _splitTokens = RegExp(r'[ -]');

  QuestionStatus checkAnswer(final String origAnswer) {
    var answerTokens = getTokens(origAnswer);
    // print('Key: ${answerTokens.toString()}');
    // print('Answer: $_answers');

    var result = _answers.match(answerTokens);
    if (result != null) {
      // Check if we've been cancelled (view answer or similar selected)
      if (cancelled) return QuestionStatus.cancelled;

      // Check if we've seen the answer before
      // (Lists are never equal so contains doesn't work here)
      for (var rightAnswer in _rightAnswers) {
        if (listEquals(rightAnswer, result)) {
          return QuestionStatus.duplicate;
        }
      }

      // Add the answer to the seen set
      _rightAnswers.add(result);

      // Check if there's more needed to complete
      if (_rightAnswers.length != _question.mustAnswer) {
        return QuestionStatus.moreNeeded;
      }

      // Return correct
      return QuestionStatus.correctOnce;
    }
    return QuestionStatus.incorrect;
  }

  List<String> getTokens(final String input) {
    // Treat hyphenated words as two words for matching.
    var answerTokens = <String>[];
    for (var token in input.split(_splitTokens)) {
      var newToken = _prepToken(token);
      if (newToken != null) {
        answerTokens.add(newToken);
      }
    }
    return answerTokens;
  }

  // TODO(jeffbailey): Handle 4th vs 4
  String? _prepToken(String token) {
    // Apostrophes are corrected inside the stemmer, but it doesn't match
    // stopwords.  This way we catch didn't vs didn’t
    // TODO(jeffbailey): This seems like a bug that should be reporting to NLTK.
    token = token
        .replaceAll('\u2019', '\x27')
        .replaceAll('\u2018', '\x27')
        .replaceAll('\u201B', '\x27');

    // 3. Strip punctuation
    token = token.replaceAll(_stripPunctuation, '');

    // 4. Make it lower case
    token = token.toLowerCase();

    // 5. Remove Stopwords - This should happen as part of stemming.
    // TODO(jeffbailey): filter not from stopwords, it's semantically important
    if (stopWords.contains(token)) return null;

    // 4. Filter empty words
    if (token.isEmpty) return null;

    // 6. Stem.
    token = _stemmer.stem(token);

    return token;
  }
}
