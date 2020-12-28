import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';
import 'package:collection/collection.dart';
import 'package:stemmer/stemmer.dart';

class QuestionContext extends ChangeNotifier {
  final BuildContext _context;
  final PorterStemmer _stemmer = PorterStemmer();

  QuestionContext(this._context);

  Question get question => _context.read<QuestionStorage>().questions[_cursor];

  int _cursor = 0;

  void prevQuestion() {
    setQuestion(_cursor - 1);
  }

  void nextQuestion() {
    setQuestion(_cursor + 1);
  }

  void setQuestion(int cursor) {
    if (cursor < 0) return;
    if (_context.read<QuestionStorage>().questions.length < (cursor + 1))
      return;
    _cursor = cursor;
    notifyListeners();
  }

  // The following needs to happen in checkAnswer:
  // Lower Case
  // Strip punctuation
  // Iterate over all answers
  // Remove stopwords
  // Convert numbers to words
  // Apply stemmer
  bool checkAnswer(String answer) {
    List<String> answerTokens = List();
    List<String> keyTokens = List();

    for (var token in answer.split(' ')) {
      token = _prepToken(token);
      if (token != null) {
        answerTokens.add(token);
      }
    }

    for (var token in question.answers[0].split(' ')) {
      token = _prepToken(token);
      if (token != null) {
        keyTokens.add(token);
      }
    }

    print("Answer: " + answerTokens.toString());
    print("Key: " + keyTokens.toString());

    if (ListEquality().equals(answerTokens, keyTokens)) return true;
    return false;
  }

  String _prepToken(String token) {
    token = token.toLowerCase();
    if (token == "the") return null;
    token = _stemmer.stem(token);
    return token;
  }
}
