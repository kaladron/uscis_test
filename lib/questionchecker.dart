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

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/stemmer/SnowballStemmer.dart';

enum QuestionStatus {
  correct,
  incorrect,
  moreNeeded,
  cancelled,
}

class QuestionChecker {
  final Question _question;

  QuestionChecker(Question question) : _question = question;

  final _stemmer = SnowballStemmer();

  final Set<String> _stopWords = HashSet.from([
    'i',
    'me',
    'my',
    'myself',
    'we',
    'our',
    'ours',
    'ourselves',
    'you',
    "you're",
    "you've",
    "you'll",
    "you'd",
    'your',
    'yours',
    'yourself',
    'yourselves',
    'he',
    'him',
    'his',
    'himself',
    'she',
    "she's",
    'her',
    'hers',
    'herself',
    'it',
    "it's",
    'its',
    'itself',
    'they',
    'them',
    'their',
    'theirs',
    'themselves',
    'what',
    'which',
    'who',
    'whom',
    'this',
    'that',
    "that'll",
    'these',
    'those',
    'am',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'being',
    'have',
    'has',
    'had',
    'having',
    'do',
    'does',
    'did',
    'doing',
    'a',
    'an',
    'the',
    'and',
    'but',
    'if',
    'or',
    'because',
    'as',
    'until',
    'while',
    'of',
    'at',
    'by',
    'for',
    'with',
    'about',
    'against',
    'between',
    'into',
    'through',
    'during',
    'before',
    'after',
    'above',
    'below',
    'to',
    'from',
    'up',
    'down',
    'in',
    'out',
    'on',
    'off',
    'over',
    'under',
    'again',
    'further',
    'then',
    'once',
    'here',
    'there',
    'when',
    'where',
    'why',
    'how',
    'all',
    'any',
    'both',
    'each',
    'few',
    'more',
    'most',
    'other',
    'some',
    'such',
    'no',
    'nor',
    'not',
    'only',
    'own',
    'same',
    'so',
    'than',
    'too',
    'very',
    's',
    't',
    'can',
    'will',
    'just',
    'don',
    "don't",
    'should',
    "should've",
    'now',
    'd',
    'll',
    'm',
    'o',
    're',
    've',
    'y',
    'ain',
    'aren',
    "aren't",
    'couldn',
    "couldn't",
    'didn',
    "didn't",
    'doesn',
    "doesn't",
    'hadn',
    "hadn't",
    'hasn',
    "hasn't",
    'haven',
    "haven't",
    'isn',
    "isn't",
    'ma',
    'mightn',
    "mightn't",
    'mustn',
    "mustn't",
    'needn',
    "needn't",
    'shan',
    "shan't",
    'shouldn',
    "shouldn't",
    'wasn',
    "wasn't",
    'weren',
    "weren't",
    'won',
    "won't",
    'wouldn',
    "wouldn't"
  ]);

  // I don't love reinitializing this per question.
  final _stripPunctuation = RegExp(r"[^\w\s']+");

  QuestionStatus checkAnswer(String origAnswer) {
    var answerTokens = getTokens(origAnswer);
    print("Key: ${answerTokens.toString()}");

    for (var answer in _question.allAnswers) {
      var keyTokens = getTokens(answer);
      print("Answer: ${answerTokens.toString()}");
      if (ListEquality().equals(answerTokens, keyTokens)) {
        return QuestionStatus.correct;
      }
    }
    return QuestionStatus.incorrect;
  }

  List<String> getTokens(String input) {
    // Treat hyphenated words as two words for matching.
    var answer = input.replaceAll('-', ' ');
    List<String> answerTokens = [];
    for (var token in answer.split(' ')) {
      var newToken = _prepToken(token);
      if (newToken != null) {
        answerTokens.add(newToken);
      }
    }
    return answerTokens;
  }

  // TODO(jeffbailey): Handle 4th vs 4
  String? _prepToken(String token) {
    // 3. Strip punctuation
    token = token.replaceAll(_stripPunctuation, '');

    // 4. Filter empty words
    if (token.isEmpty) return null;

    // 6. Stem.
    token = _stemmer.stem(token);

    // 5. Remove Stopwords - This should happen as part of stemming.
    // TODO(jeffbailey): filter not from stopwords, it's semantically important
    if (_stopWords.contains(token)) return null;

    return token;
  }
}
