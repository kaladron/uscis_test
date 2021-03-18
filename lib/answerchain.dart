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
      if (d.distance(key, words.last) <= 1) {
        nextChain = _next[key];
        break;
      }
    }
    // No, but was this an OK place to stop?
    if (nextChain == null && _okEnd) {
      return answerWords;
    }
    // Nope!
    if (nextChain == null) {
      return null;
    }

    answerWords.add(words.removeLast());
    return nextChain.match(words, answerWords);
  }
}
