import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';

class QuestionContext extends ChangeNotifier {
  final BuildContext _context;

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
    if (_cursor == 0) return;
    if (_context.read<QuestionStorage>().questions.length == (_cursor + 1))
      _cursor = cursor;
    notifyListeners();
  }
}
