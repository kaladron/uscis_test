import 'package:flutter/services.dart';

class QuestionStorage {
  Future<String> readFile() async {
    try {
      var contents = await rootBundle.loadString('2008.json');

      return contents;
    } catch (e) {
      return e.toString();
    }
  }
}
