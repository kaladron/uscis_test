import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';

class QuestionContext extends ChangeNotifier {
  final BuildContext _context;

  QuestionContext(this._context);

  Question get question => _context.read<QuestionStorage>().questions[_cursor];

  int _cursor = 0;

  // TODO(jeffbailey): Bounds check these.
  void prevQuestion() {
    _cursor--;
    notifyListeners();
  }

  void nextQuestion() {
    _cursor++;
    notifyListeners();
  }

  void setQuestion(int cursor) {
    _cursor = cursor;
    notifyListeners();
  }
}
