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

import 'package:test/test.dart';
import 'package:uscis_test/answerchain.dart';

void main() {
  group('AnswerChain tests', () {
    test('empty match', () {
      var chain = AnswerChain();
      chain.add([]);
      expect(chain.match([]), []);
    });

    test('simple match', () {
      var chain = AnswerChain();
      chain.add(['foo']);
      chain.add(['foo', 'bar', 'baz']);
      chain.add(['foo', 'bar', 'bar']);
      chain.add(['foo', 'bar', 'quux']);
      chain.add(['foo', 'baz', 'baz']);
      chain.add(['foo', 'quux', 'baz']);

      expect(chain.match(['foo'].reversed.toList()), ['foo']);
      expect(chain.match(['foo', 'bar', 'quux'].reversed.toList()),
          ['foo', 'bar', 'quux']);

      expect(chain.match(['foo', 'quux'].reversed.toList()), null);

      // Test remaining words
      var remaining = ['foo', 'bar', 'quux', 'ooga', 'booga'].reversed.toList();
      expect(chain.match(remaining), ['foo', 'bar', 'quux']);
      // Remaining words are reversed
      expect(remaining, ['booga', 'ooga']);
    });

    test('levenshtein match', () {
      var chain = AnswerChain();
      chain.add(['sox']);

      expect(chain.match(['sax']), ['sox']);
    });

    test('test multiquestionwalker', () {
      var chain = AnswerChain();
      chain.add(['foo']);
      chain.add(['foo', 'bar', 'baz']);
      chain.add(['foo', 'bar', 'bar']);
      chain.add(['foo', 'bar', 'quux']);
      chain.add(['foo', 'baz', 'baz']);
      chain.add(['foo', 'quux', 'baz']);

      var walker =
          MultiQuestionWalker(chain, ['foo', 'foo', 'bar', 'baz', 'foo']);
      var results = <List<String>?>[];
      for (var answer in walker) {
        results.add(answer);
      }
      expect(results.length, 3);
    });
  });
}
